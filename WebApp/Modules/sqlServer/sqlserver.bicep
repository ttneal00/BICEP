param location string
param sqlserverName string
param tags object

// Private Endpoint Vars and Params
param  sqlDnsZoneId string
param  subnetId string
param  groupId string
param sqlLogin string
param sqlAdObjectId string
param akvName string
param kvRgName string
param sharedsvcsKeyVaultId string

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

param sqlServerManagedIdentityName string

// Resource Deployments

var keyVaultSecretsReaderRole = resourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
var keyVaultCertificatesOfficer = resourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')

resource akv 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: akvName
  scope: resourceGroup(kvRgName)
}

resource sqlId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: sqlServerManagedIdentityName
  location: location
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlserverName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${sqlId.id}' : {}
    }
  }

  tags: tags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    administrators:{
      administratorType:'ActiveDirectory'
      principalType: 'Group'
      login: sqlLogin
      tenantId: subscription().tenantId
      sid: sqlAdObjectId
      azureADOnlyAuthentication: true
   
    }
  primaryUserAssignedIdentityId: sqlId.id
  }
}

module sqlPe '../privateEndpoint/privateEndpoint.bicep' = {
  name: 'pe${sqlServer.name}'
  params: {
    groupId: groupId
    location: sqlServer.location
    privateEndpointName: 'pe${sqlServer.name}'
    privateLinkServiceId: sqlServer.id
    subnetId: subnetId
    privateDnsZoneId: sqlDnsZoneId
    pvtEndpointDnsGroupName: 'pegrp${sqlServer.name}'
  }
}

resource kvAppGwSecretsUserRole 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(sqlId.id, akv.id, keyVaultSecretsReaderRole)
  properties: {
    roleDefinitionId: keyVaultSecretsReaderRole
    principalType: 'ServicePrincipal'
    principalId: sqlId.properties.principalId
  }
}

resource kvCertificatesOfficer 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(sqlId.id, akv.id, keyVaultCertificatesOfficer)
  properties: {
    roleDefinitionId: keyVaultCertificatesOfficer
    principalType: 'ServicePrincipal'
    principalId: sqlId.properties.principalId
  }
}

output sqlId string = sqlServer.id
output sqlServerName string = sqlServer.name
output sqlAdminLogin string = sqlServer.properties.administratorLogin
output sqlPeId string = sqlPe.outputs.peId
output sqlInterfaceId string = sqlPe.outputs.penetworkInterfaceId 


