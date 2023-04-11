// param kvApName string
param objectId string
param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource kvAp 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' =  {
  name: 'add'
  parent: kv
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        permissions: {
          secrets: [
            'get'
            'set'
          ]
          certificates: [
            'get'
            'create'
          ]
          keys: [
            'get'
            'create'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  
  }

}

