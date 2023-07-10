targetScope = 'subscription'
param prefix string
param location string
param globaltags object = {
  modifiedDate: utcNow()
}

// Enviornment




// Resource Group Vars and Params
param connectRgName string
param computeRgName string
param supportRgName string


// virtual network vars and params
param hub01Network string
param hubName string
param publicSubnet string
param supportSubnet string
param dnsResolverInboundSubnet string
param dnsResolverOutboundSubnet string
param vpnGatewaySubnet string
param computeSubnet string
param vnetIntegrationSubnet string
param hub01Prefix string = '${hub01Network}0.0/16'
param vpnClientAddressCIDR string
param vpnClientProtocols string
param vpnGatewaySku string

var resourceGroups = [
  {
    name: '${prefix}-${connectRgName}'
    location: location
  }
  {
    name: '${prefix}-${computeRgName}'
    location: location 
  }
]

module rgroups 'Modules/resourceGroup/ResourceGroup.bicep' =[for (group, i) in resourceGroups: {
  name: group.name
  params: {
    location: location
    resourceGroupName: group.name
    tags:globaltags
  }
}]

module hub01 'Modules/Network/network.bicep' = {
  scope: resourceGroup(rgroups[0].name)
  name: '${prefix}-${hubName}-01'
  params: {
    computeSubnetName: '${hubName}-compute-sn'
    computeSubnetPrefix:  '${hub01Network}${computeSubnet}'
    dnsResolverInboundSubnetName: '${hubName}-dnsresolverinbound-sn'
    dnsResolverInboundSubnetPrefix:'${hub01Network}${dnsResolverInboundSubnet}'
    dnsResolverOutboundSubnetName:  '${hubName}-dnsresolveroutbound-sn'
    dnsResolverOutboundSubnetPrefix: '${hub01Network}${dnsResolverOutboundSubnet}'
    tags: globaltags
    location: location
    publicAddressPrefix: '${hub01Network}${publicSubnet}'
    publicSubnetName: '${hubName}-public-sn'
    supportServicvesSubnetName: '${hubName}-support-sn'
    supportServicvesSubnetPrefix: '${hub01Network}${supportSubnet}'
    vnetAddress: hub01Prefix
    vnetName: '${prefix}-${hubName}-01'
    vnetIntegrationSubnetName:'${hubName}-vnetInt-sn'
    vnetIntegrationSubnetPrefix: '${hub01Network}${vnetIntegrationSubnet}'
    VPNGatewaySubnetPrefix:  '${hub01Network}${vpnGatewaySubnet}'
  }
}

module privateDns 'Modules/dnsZones/privateDnsZones.bicep' = {
  scope: resourceGroup(rgroups[0].name)
  name: '${prefix}-privateDnsZones-01'
  params: {
    vpnVnetId: hub01.outputs.vnetid
    tags:globaltags
  }
}

module dnsResolver 'Modules/dnsResolvers/dnsResolvers.bicep' = {
  scope: resourceGroup(rgroups[0].name)
  name: '${prefix}-dnsResolver-01'
  params: {
    dnsResolvercfgname: '${prefix}-dnsResolver-01'
    inboundEndpointsName: '${prefix}-inboundEP-01'
    inboundSubnetId: hub01.outputs.subnets[3].id
    location: location
    outboundEndpointsName: '${prefix}-outboundEP-01'
    outboundSubnetId: hub01.outputs.subnets[4].id
    tags:globaltags
    virtualNetworkId: hub01.outputs.vnetid
  }
}
module appServicePlan 'Modules/appServicePlan/appServiceplan.bicep' = {
  scope: resourceGroup(rgroups[1].name)
  name:  '${prefix}-AppServicePlan-01'
  params: {
    appServicePlanName: '${prefix}-AppServicePlan-01'
    location: location
    skuSize: 'B1'
    tags:globaltags
  }
}

module webApp 'Modules/appServicePlan/webApp.bicep' = {
  scope: resourceGroup(rgroups[1].name)
  name: '${prefix}-webApp-01'
  params: {
    appDnsZoneId: privateDns.outputs.WebAppDnsId
    appServicePlanId: appServicePlan.outputs.id
    kind: 'Linux'
    location: location
    tags:globaltags
    vnetIntegrationSubnetId: hub01.outputs.subnets[5].id
    webAppName: '${prefix}-webApp-01'
    webAppSubnetId: hub01.outputs.subnets[1].id
  }
}

param vpnGatewayName string

module vpnGateway 'Modules/vpnGateway/vpnGateway.bicep' = {
  scope: resourceGroup(rgroups[0].name)
  name: '${prefix}-${vpnGatewayName}-01'
  params: {
    gatewayName: '${prefix}-${vpnGatewayName}-01'
    gatewaySku: vpnGatewaySku
    location: location
    privateIPAllocationMethod: 'Dynamic'
    subnetid: hub01.outputs.subnets[6].id
    tags:globaltags
    tenantId: subscription().tenantId
    vpnClientAddressCIDR: vpnClientAddressCIDR
    vpnClientProtocols: vpnClientProtocols
  }
}


