param location string
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
param environmentLabel string
param environmentName string
param storageAccountConnectionString string
param appInsightsConnectionString string

var appDeployments = [
  {
    name: 'webapp1-${environmentLabel}01'
    kind: 'Linux'
    properties: {
      ASPNETCORE_ENVIRONMENT: environmentName
      AzureWebJobsStorage: storageAccountConnectionString
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    }
   }
  {
    name: 'webapp2-${environmentLabel}01'
    kind: 'Linux'
    properties: {
      ASPNETCORE_ENVIRONMENT: environmentName
      AzureWebJobsStorage: storageAccountConnectionString
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    }
  }
]

// Resource Deployment
resource webApps 'Microsoft.Web/sites@2022-03-01' =[for app in appDeployments: {
  name: '${app.name}'
  location: location
  kind: app.kind
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    enabled: webAppEnabled
    hostNameSslStates: [
      {
        hostType: 'Standard'
        name: '${app.name}${webDomain}'
        sslState: 'Disabled'
        
      }
      {
        hostType: 'Repository'
        name: '${app.name}.scm${webDomain}'
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
  }
}]

module prvEndPoint '../privateEndpoint/privateEndpoint.bicep' = [for app in appDeployments:{
  name: '${environmentLabel}pe${app.name}'
  params: {
    groupId: 'sites'
    location: location
    privateDnsZoneId: appDnsZoneId
    privateEndpointName: 'pe${app.name}'
    privateLinkServiceId: resourceId('Microsoft.Web/Sites',app.name) 
    pvtEndpointDnsGroupName: 'pegrp${app.name}'
    subnetId: webAppSubnetId
  }
  dependsOn:[
    webApps
  ]
}]

module webAppsSettings './appSettings.bicep' =  [for app in appDeployments: {
  name: '${app.name}-config'
  params: {
    properties: app.properties
    webAppName: app.name
  }
  dependsOn: [
    webApps
  ]
}]
