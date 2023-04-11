targetScope = 'subscription'

// Variables and Params

param locationEastus string = 'eastus'
param environmentName string
param environmentLabel string 
param applicationName string 
param dateTime string = utcNow('d')
param resourceGroupPrefix string
param dnsNamingPrefix string
param vNetNamingPrefix string
param subnetNamingPrefix string

@description('first two octets of the network address.')
param vNetNetwork string


@description('Prefix for all network related resources')
param networkGroupName string

@description('Prefix for all compute related resources')
param computeGroupName string

@description('Prefix for all storage and database related resources')
param storageSvcsGroupName string

@description('Prefix for all support and shared services related resources')
param supportSvcsGroupName string

@description('Used to establish global tags across all resources and resource groups')
param globalTags object = {
  environment : environmentName 
  CreationDate : dateTime
  Application: applicationName
}

@description('Array leveraged to build all resource groups')
param resourceGroups array = [
  {
    name: '${resourceGroupPrefix}-${networkGroupName}-${environmentLabel}'
    location: locationEastus
  }
  {
    name: '${resourceGroupPrefix}-${computeGroupName}-${environmentLabel}'
    location: locationEastus
  }
  {
    name: '${resourceGroupPrefix}-${storageSvcsGroupName}-${environmentLabel}'
    location: locationEastus
  }
  {
    name: '${resourceGroupPrefix}-${supportSvcsGroupName}-${environmentLabel}'
    location: locationEastus
  }
]

//Deploy Resources

module resgroup 'Modules/resourceGroup/resourceGroup.bicep' = [for rgroup in resourceGroups:{
  name: rgroup.name
  params: {
    location: rgroup.location
    resourceGroupName: rgroup.name
    tags: globalTags
  }
}]


module Spoke01 'Modules/Network/network.bicep' = {
  scope: resourceGroup(resgroup[0].name)
  name: '${vNetNamingPrefix}${environmentLabel}-${networkGroupName}-01'
  params: {
    computeSubnetName: '${subnetNamingPrefix}app-${environmentLabel}-${networkGroupName}-01'
    computeSubnetPrefix: '${vNetNetwork}10.0/24'
    appVnetIntSubnetName: '${subnetNamingPrefix}vnetint-${environmentLabel}-${networkGroupName}-01'
    appVnetIntSubnetPrefix: '${vNetNetwork}20.0/24'
    datasvcSubnetName: '${subnetNamingPrefix}dbst-${environmentLabel}-${networkGroupName}-01'
    datasvcSubnetPrefix: '${vNetNetwork}30.0/24'
    environmentLabel: environmentLabel
    globaltags: globalTags
    location: locationEastus
    publicAddressPrefix: '${vNetNetwork}40.0/24'
    publicSubnetName: '${subnetNamingPrefix}pub-${environmentLabel}-${networkGroupName}-01'
    supportServicvesSubnetName: '${subnetNamingPrefix}support-${environmentLabel}-${networkGroupName}-01'
    supportServicvesSubnetPrefix: '${vNetNetwork}50.0/24'
    vnetAddress: '${vNetNetwork}0.0/16'
    vnetName: '${vNetNamingPrefix}${environmentLabel}-${networkGroupName}-01'
  }
}

module privateDNSZone 'Modules/dnsZones/privateDnsZones.bicep' = {
  scope: resourceGroup(resgroup[0].name)
  name: '${dnsNamingPrefix}${environmentLabel}-${supportSvcsGroupName}-01'
  params: {
    VnetId: Spoke01.outputs.supportServicvesSubnetId
  }
}

module storageAccount 'Modules/storageAccount/storageAccount.bicep' = {
  scope: resourceGroup(resgroup[2].name)
  name: '${storageSvcsGroupName}sa'
  params: {
    location: locationEastus
    privateDnsZoneId: privateDNSZone.outputs.blobDnsZoneId
    storageAccountName: toLower('${environmentLabel}${storageSvcsGroupName}')
    storageKind: 'StorageV2'
    storageSkuName: 'Standard_LRS'
    subnetId: Spoke01.outputs.datasvcSubnetID
  }
}

module appInsights 'Modules/appInsights/appInsights.bicep' = {
  scope: resourceGroup(resgroup[3].name)
  name: 'appInsights${supportSvcsGroupName}'
  params: {
    applicationInsightsName: toLower('${environmentLabel}${supportSvcsGroupName}-appInsights')
    globalTags: globalTags
    location: locationEastus
  }
}

module appServicePlan 'Modules/appServicePlan/appServiceplan.bicep' = {
  scope: resourceGroup(resgroup[1].name)
  name: 'aspln${computeGroupName}-${environmentLabel}'
  params: {
    appServicePlanName: 'aspln${computeGroupName}-${environmentLabel}'
    location: locationEastus
    skuSize: 'B1'
  }
}

module webApps 'Modules/appServicePlan/webApp.bicep' = {
  scope: resourceGroup(resgroup[1].name)
  name: '${environmentLabel}-${supportSvcsGroupName}-webapps'
  params: {
    appDnsZoneId: privateDNSZone.outputs.WebAppDnsId
    appServicePlanId: appServicePlan.outputs.id
    location: locationEastus
    vnetIntegrationSubnetId: Spoke01.outputs.appVnetIntSubnetID
    webAppSubnetId: Spoke01.outputs.computeSubnetID
    appInsightsConnectionString: appInsights.outputs.connectionString
    environmentLabel:environmentLabel
    environmentName: environmentName
    storageAccountConnectionString: storageAccount.outputs.connectionString
  }
  dependsOn: []
}
