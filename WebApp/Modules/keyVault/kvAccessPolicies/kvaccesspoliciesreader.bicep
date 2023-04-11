// param kvApName string
param subscriptionId string
param resourceGroupName string
param keyVaultName string
param managedIdentityName string



resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource kvAp 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' =  {
  name: 'add'
  parent: kv
  properties: {
    accessPolicies: [
      {
        objectId: '${subscriptionId}/resourcegroups/${resourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${managedIdentityName}'
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
          keys: [
            'get'
            'list'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  
  }

}

