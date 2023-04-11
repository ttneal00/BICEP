param storageAccountName string
param location string
param allowBlobPublicAccess bool = false
param privateDnsZoneId string
param subnetId string
param publicNetworkAccess string = 'Disabled'

var privateEndpoints = [
  {
    groupId: 'blob'
  }
  // {
  //   groupId: 'dfs'
  // }
  // {
  //   groupId: 'queue'
  // }
  // {
  //   groupId: 'file'
  // }
  // {
  //   groupId: 'web'
  // }
  // {
  //   groupId: 'table'
  // }
]

@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_ZRS'
])
param storageSkuName string
@allowed([
  'BlobStorage'
  'StorageV2'
])
param storageKind string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${storageAccountName}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: storageSkuName
  }
  kind: storageKind
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: allowBlobPublicAccess
    publicNetworkAccess: publicNetworkAccess

  }
  
}

module storageAccountPrivateEndpoint '../privateEndpoint/privateEndpoint.bicep' =[for privateEndpoint in privateEndpoints: {
  name: 'pe${storageAccount.name}-${privateEndpoint.groupId}'
  params: {
    groupId: privateEndpoint.groupId
    location: location
    privateDnsZoneId: privateDnsZoneId
    privateEndpointName: 'pe${storageAccount.name}-${privateEndpoint.groupId}'
    privateLinkServiceId: storageAccount.id
    pvtEndpointDnsGroupName: 'pegrp${storageAccount.name}'
    subnetId: subnetId
  }
}]

var key = storageAccount.listKeys().keys[0].value

output id string = storageAccount.id
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output connectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${key}'

