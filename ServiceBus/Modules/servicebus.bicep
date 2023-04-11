@description('locaton of the resource deployment - set by main.bicep')
param location string

@description('the namespace of the servicebus - set by main.bicep')
param serviceBusName string
param globalTags object


@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('related sku to deploy')
param serviceBusSku string

@description('The number of partitions of a Service Bus namespace. This property is only applicable to Premium SKU namespaces. ')
@allowed([
  0
  1
  2
  4
])
param premiumMessagingPartitions int

@allowed([
  '1.0'
  '1.1'
  '1.2'
])
@description('The minimum TLS version for the cluster to support, e.g. 1.2')
param minimumTlsVersion string

@allowed([
  'Disabled'
  'Enabled'
  'SecuredByPerimeter'
])

@description('This determines if traffic is allowed over public network. By default it is enabled.')
param publicNetworkAccess string

@description('This property disables SAS authentication for the Service Bus namespace.')
param disabledLocalAuth bool

@description('Enabling this property creates a Premium Service Bus Namespace in regions supported availability zones.')
param zoneRedundant bool 


@description('Deploys Servicebus Namespace')
resource serviceBusNameSpace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: serviceBusSku
  }
  properties: {
    premiumMessagingPartitions: premiumMessagingPartitions
    minimumTlsVersion:  minimumTlsVersion
    publicNetworkAccess:  publicNetworkAccess
    disableLocalAuth:  disabledLocalAuth
    zoneRedundant: zoneRedundant
  }
   tags: globalTags
}

@description('Creates Sas token leveraged by logicApp mananged identity')
resource sasKey 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-10-01-preview' = {
  name: 'LogicApp${serviceBusNameSpace.name}'
  parent: serviceBusNameSpace
  properties: {
    rights:  [
      'Listen'
      'Send'
    ]
  }
}

output serviceBusEndpoint string = serviceBusNameSpace.properties.serviceBusEndpoint
output serviceBusId string = serviceBusNameSpace.id
output logicAppSasId string = sasKey.id
output logicAppSasName string = sasKey.name
output logicAppSasApiVersion string = sasKey.apiVersion


