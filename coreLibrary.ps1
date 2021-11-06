
function Get-AzRestApiCachedAccessToken() {
	
	# https://www.powershellgallery.com/packages/Az.Profile/0.7.0
	# Install-Module Az.Profile

	$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile

	if(-not $azureRmProfile.Accounts.Count) {
		Write-Error "Ensure you have logged in before calling this function."    
	}

	$currentAzureContext = Get-AzContext
	$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
  
	Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
	$token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)

	return $token.AccessToken

}

$subscriptionLookup=@{
    "d"=@{
             account='giovanni.ramundi@walgreens.com'
             envGroup='nprod'
             subName="gs-nprod-digital-decoupling-platform-01"

            }
         
    "t"=@{
            account='giovanni.ramundi@walgreens.com'
            envGroup=@('nprod')
            subName="gs-nprod-digital-decoupling-platform-01"
   
        }
    "s"=@{

            account='giovanni.ramundi@walgreens.com'
            envGroup=@('nprod')
            subName="gs-nprod-digital-decoupling-platform-01"
   
        }
    "p"=@{
            account='giovanni.ramundi@walgreens.com'
             
            envGroup=@('prod')
            subName="gs-prod-digital-decoupling-platform-01"
   
        }
    "MySandbox"=@{

            account='appinsight@giovanniramundi.co.uk'
            password='1pp3ns3ght$'
            envGroup=@('Sandbox')
            subName="sandboxLab"
    }    
}
