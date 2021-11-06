param
(
  [Parameter (Mandatory = $false) ]  [string]    $env='MySandbox' ,
  [Parameter (Mandatory = $false) ]  [string]    $appInsName='testAppInsight'
  
)

function generateApikey($appInsName,$rg){

        #$env=$appInsightName.Substring($appInsightName.IndexOf('-ai')-1, 1)
        Write-Information "Generating Api Key for AppInsight:$appInsName ResourceGroup:$rg"
        $apiKeyDescription="monitorKey$appInstName"
        $permissions = @("ReadTelemetry")
        $apiKey=New-AzApplicationInsightsApiKey -ResourceGroupName $rg -Name $appInsName -Description $apiKeyDescription -Permissions $permissions
        return $apikey.ApiKey

}




function queryAppInsight($appInsName,$rg,$apiKey){
    
        #curl "https://api.applicationinsights.io/v1/apps/88624a03-47ed-4cb7-92bc-52b00e2a7816/metrics/requests/count" -H "X-Api-Key: ayafzlaf048llgvvgesbzhl6xonbjn4m86uutrob" 
        #eapi-rt-oms-location-error-handler-t-ai
        #First Generate API Keys from Portal https://dev.applicationinsights.io/quickstart/
        #Azure Application Insights REST API
        $appId=(Get-AzApplicationInsights -ResourceGroupName $rg -Name $appInsName).AppId
        $url='https://api.applicationinsights.io/v1/apps/'+$appId+'/metrics/requests/count?timespan=P20D'
        write-output "Query Appinsight REst APi Endpoint $url"

        $response=Invoke-WebRequest -Uri $url -Headers @{"accept"="application/json"; "x-api-key"= $apiKey} -UseBasicParsing

        write-output $response.Content

}


function loginAzure($sub,$account,$pass)
{
        Write-Output "Subscription: $sub -- AzureAccount:$account---password:$pass"
        $azurePassword = ConvertTo-SecureString $pass -AsPlainText -Force

        $psCred = New-Object System.Management.Automation.PSCredential($account, $azurePassword)
        Login-AzAccount -Credential $psCred
        Select-AzSubscription -SubscriptionName $sub 
}


. $PSScriptRoot/coreLibrary.ps1

Write-Output "Enviroment:$env"

loginAzure -Sub $subscriptionLookup.Item($env).subName -account $subscriptionLookup.Item($env).account -pass $subscriptionLookup.Item($env).password

#Check if the appInisght Exist in the subscription
$rgAppIns=(Get-AzResource -Name $appInsName).ResourceGroupName
if(! $rgAppIns){
    Write-Output "Application Insight:$appInsName Does not Exists in the subscription:$($subscriptionLookup.Item($env).subName)"

}



write-OutPut "enviroment:$env appInsightName:$appInsName"

$loadKeys=Import-Csv -Path .\appInsightsKeys.csv

$apiKey=($loadKeys.Where({$PSItem.appInsightName.replace('"','') -eq $appInsName})).apiKey
#Write-Output $apiKey
if (! $apiKey ){
    Write-Output "Generate an API Key for appInisght:$appInsName"
    $apiKeyObj=(Get-AzApplicationInsightsApiKey -ResourceGroupName $rgAppIns -Name $appInsName)
    if (($apiKeyObj).Description.Contains("monitorKey")){
        
        Remove-AzApplicationInsightsApiKey -ResourceGroupName $rgAppIns -Name $appInsName -ApiKeyId $apiKeyObj.Id
    }

    $apiKey = generateApikey -appInsName $appInsName -rg $rgAppIns
    $apiKey
    #$newRow = New-Object PsObject -Property @{ appInsightName = $appInsName; apiKey = $apiKey  }
    #$newRow
    #$loadKeys += $newRow
    $loadkeys
    $loadKeys | Export-Csv .\appInsightsKeys.csv -Delimiter ','
    queryAppInsight  -appInsName $appInsName -rg $rgAppIns -apiKey $apiKey
}
else {
    queryAppInsight  -appInsName $appInsName -rg $rgAppIns -apiKey $apiKey
}
