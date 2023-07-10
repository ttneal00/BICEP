param utcValue string = utcNow()

@description('Specifies the name of the user-assigned managed identity.')
param identityName string

var roleAssignmentId_var = guid('${resourceGroup().id}contributor')
var contributorRoleDefinitionId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: resourceGroup().location
}

resource roleAssignmentId 'Microsoft.Authorization/roleAssignments@2018-09-01-preview' = {
  name: roleAssignmentId_var
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: reference(identity.id, '2018-11-30').principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
}

resource demoSample 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'demoSample'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '5.0'
    timeout: 'PT30M'
    scriptContent: '\r\n          Write-Host \'Hello World\'\r\n        '
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
