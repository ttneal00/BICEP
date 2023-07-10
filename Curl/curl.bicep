param identityName string = 'AzPwrShUser'
param location string = 'eastus'
// param currentTime string = utcNow() 

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
}


resource curl 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'curl'
  kind: 'AzurePowerShell'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
  //  forceUpdateTag: currentTime
    azPowerShellVersion: '6.4'
    scriptContent:  'Invoke-WebRequest -Uri https://ipv4.icanhazip.com'
    retentionInterval: 'P1D'
  }
}


output scriptContent string = curl.properties.scriptContent
//output outputs object = curl.properties.outputs
