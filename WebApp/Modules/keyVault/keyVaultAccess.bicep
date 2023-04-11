targetScope = 'subscription'

param keyVaultId string
param managedId string
param roleId string

resource kvAppGwSecretsUserRole 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(keyVaultId, managedId, roleId)
  properties: {
    roleDefinitionId: roleId
    principalType: 'ServicePrincipal'
    principalId: managedId
  }

}
