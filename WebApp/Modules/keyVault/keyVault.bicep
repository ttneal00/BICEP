// Global Parameters
param location string
param tags object

// Key Vault Params and Vars
param kvname string 
@allowed([
  'standard'
  'premium'
])
param skufamily string 

// Private Endpoint Vars and Params
param kvDnsZoneId string
param kvSubnetId string
param agwManagedId string

var keyVaultSecretsReaderRole = resourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
var keyVaultCertificatesOfficer = resourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
var keyVaultSecretsUserRole = resourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

// Resource Deployment
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: kvname
  tags: tags
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skufamily
    }
    tenantId: subscription().tenantId
    enableSoftDelete: true
    enableRbacAuthorization: true
    accessPolicies: []
  }
}

module kvPe '../privateEndpoint/privateEndpoint.bicep' = {
  name: 'pe${kv.name}'
  params: {
    groupId: 'vault'
    location: kv.location
    privateDnsZoneId: kvDnsZoneId
    privateEndpointName: 'pe${kv.name}'
    privateLinkServiceId: kv.id
    pvtEndpointDnsGroupName: 'pegrp${kv.name}'
    subnetId: kvSubnetId
  }
}

resource kvAppGwSecretsUserRole 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(kv.id, agwManagedId, keyVaultSecretsReaderRole)
  scope: kv
  properties: {
    roleDefinitionId: keyVaultSecretsReaderRole
    principalType: 'ServicePrincipal'
    principalId: agwManagedId
  }

}

resource kvCertificatesOfficer 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(kv.id, agwManagedId, keyVaultCertificatesOfficer)
  scope: kv
  properties: {
    roleDefinitionId: keyVaultCertificatesOfficer
    principalType: 'ServicePrincipal'
    principalId: agwManagedId
  }
}

resource kvSecretsUser 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(kv.id, agwManagedId, keyVaultSecretsUserRole)
  scope: kv
  properties: {
    roleDefinitionId: keyVaultSecretsUserRole
    principalType: 'ServicePrincipal'
    principalId: agwManagedId
  }
}

output id string = kv.id
output uri string = kv.properties.vaultUri

output keyVaultReaderRole string = keyVaultSecretsReaderRole
