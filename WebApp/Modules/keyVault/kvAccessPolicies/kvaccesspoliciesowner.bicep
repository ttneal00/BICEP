// param kvApName string
param objectId string
param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource kvApTwo 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: kv
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId

        permissions: {
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'rotate'
            'getrotationpolicy'
            'setrotationpolicy'
          ]
          certificates:[
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
          secrets: [
            'get'
            'set'
            'list'    
            'delete'
            'recover'
            'backup'
            'restore'
          ]
        }
      
      
    }
    ]
  
  }

}
