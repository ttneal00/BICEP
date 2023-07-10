param location string
param webAppName string
param webAppEnabled bool = true
param httpsOnly bool = true
param AlwaysOn bool = true
param numOfWorkers int = 1
param acrUseManagedIdentityCreds bool = false
param http20Enabled bool = true
param functionAppScaleLimit int = 0
param clientAffinityEnabled bool = true
param webDomain string = '.azurewebsites.net'
param appServicePlanId string
param appDnsZoneId string
param webAppSubnetId string
param vnetIntegrationSubnetId string
var randomString = take(uniqueString(resourceGroup().id), 4)
param tags object

@allowed([
  'functionapp'
  'Linux'
])

param kind string

// Resource Deployment
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${webAppName}${randomString}'
  location: location
  kind: kind
  identity: {
    type:'SystemAssigned'
  }
  tags: tags
  properties: {
    serverFarmId: appServicePlanId
    enabled: webAppEnabled
    hostNameSslStates: [
      {
        hostType: 'Standard'
        name: '${webAppName}${webDomain}'
        sslState: 'Disabled'
        
      }
      {
        hostType: 'Repository'
        name: '${webAppName}.scm${webDomain}'
        sslState: 'Disabled'
      }
    ]
    httpsOnly: httpsOnly
    siteConfig: {
      numberOfWorkers: numOfWorkers
      acrUseManagedIdentityCreds: acrUseManagedIdentityCreds
      alwaysOn: AlwaysOn
      http20Enabled: http20Enabled
      functionAppScaleLimit: functionAppScaleLimit
      }
    clientAffinityEnabled: clientAffinityEnabled
    vnetRouteAllEnabled: true
    virtualNetworkSubnetId: vnetIntegrationSubnetId
    publicNetworkAccess: 'Disabled'
  }
}


module prvEndPoint '../privateEndpoint/privateEndpoint.bicep' = {
  name: 'pe${webApp.name}'
  params: {
    groupId: 'sites'
    location: location
    privateDnsZoneId: appDnsZoneId
    privateEndpointName: 'pe${webApp.name}'
    privateLinkServiceId: webApp.id    
    pvtEndpointDnsGroupName: 'pegrp${webApp.name}'
    subnetId: webAppSubnetId
  }
}
