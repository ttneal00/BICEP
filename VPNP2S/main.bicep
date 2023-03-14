targetScope = 'subscription'
param prefix string
param location string
param tenantid string = subscription().tenantId
param guidValue string = newGuid()
var label = uniqueString(guidValue)

// Enviornment

var databasesuffix = environment().suffixes.sqlServerHostname
var databasesuffixname = replace(databasesuffix, '.','')


// Resource Group Vars and Params
param connectRgName string
param computeRgName string


// virtual network vars and params
param spokeName string
param spoke01Address string
param subnet01 string
param subnet02 string
param bastionSN string
param vpnSN string
var spoke01CIDR = '${spoke01Address}0.0/16'
param vpnClientAddressCIDR string
param vpnClientProtocols string
param vpnGatewaySku string

// dnsResolver Info
param dnsResolversuffix string
param dnsResolverInboundSn string
param dnsResolverOutboundSn string
var dnsResolverName = '${prefix}${dnsResolversuffix}'
var inboundEndpointsName = '${prefix}${dnsResolversuffix}IbEp'
var outboundEndpointsName = '${prefix}${dnsResolversuffix}ObEp'
var forwardingRuleSetsName = '${prefix}${dnsResolversuffix}RuleSets'


// Compute vars and params
param imageOSSku string
param imagePublisher string
param imageOffer string
param imageVersion string
param vmSize string
param vmName string
param sakind string
param storageskuname string

// BastionHost
param bastionHostName string

// Resource Group Modules
module connectRG 'Modules/ResourceGroup.bicep' = {
  name: '${prefix}${connectRgName}'
  params: {
    location: location
    resourceGroupName: '${prefix}${connectRgName}'
  }
}

module computeRG 'Modules/ResourceGroup.bicep' = {
  name: '${prefix}${computeRgName}'
  params: {
    location: location
    resourceGroupName: '${prefix}${computeRgName}'
  }
}

//Connect Modules
module virtualNetwork 'Modules/VirtualNetwork.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}${spokeName}-01'
  params: {
    location: location
    vnetAddress: spoke01CIDR
    vnetName: '${prefix}${spokeName}-01'
  }
  dependsOn:[
    connectRG
  ]
}

module cmpsubnet 'Modules/subnet.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-cmpsubnet'
  params: {
    subnetname: '${virtualNetwork.name}/${prefix}-cmpsubnet'
    addressprefix: '${spoke01Address}${subnet01}'
  }
  dependsOn: [
    virtualNetwork
  ]
}

module cmpsubnet2 'Modules/subnet.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-cmpsubnet2'
  params: {
    subnetname: '${virtualNetwork.name}/${prefix}-cmpsubnet2'
    addressprefix: '${spoke01Address}${subnet02}'
  }
  dependsOn:[
    cmpsubnet
  ]
}

module dnsResolverIbSn 'Modules/subnet.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-dnsResolverIbsn'
  params: {
    subnetname: '${virtualNetwork.name}/${prefix}-dnsResolverIbsn'
    addressprefix: '${spoke01Address}${dnsResolverInboundSn}'
  }
  dependsOn:[
    cmpsubnet
    bastionsn
  ]
}

module dnsResolverObSn 'Modules/subnet.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-dnsResolverObsn'
  params: {
    subnetname: '${virtualNetwork.name}/${prefix}-dnsResolverObsn'
    addressprefix: '${spoke01Address}${dnsResolverOutboundSn}'
  }
  dependsOn:[
    dnsResolverIbSn
    cmpsubnet
    bastionsn
  ]
}

module dnsResolver 'Modules/dnsResolvers.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: dnsResolverName
  params: {
    inboundEndpointsName: inboundEndpointsName
    inboundSubnetId: dnsResolverIbSn.outputs.subnetid
    location: location
    outboundEndpointsName: outboundEndpointsName
    outboundSubnetId: dnsResolverObSn.outputs.subnetid
    virtualNetworkId: virtualNetwork.outputs.id
    dnsResolvercfgname: dnsResolverName
  }
}

module forwardingRuleSets 'Modules/forwardingRuleSets.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: forwardingRuleSetsName
  params: {
    forwardRuleSetName: forwardingRuleSetsName
    location: location
    outboundEndpointsId: dnsResolver.outputs.outboundEndpointId
  }
}

module forwardingRules01 'Modules/forwardingRules.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: databasesuffixname
  params: {
    domainName: 'privatelink${databasesuffix}.'
    forwardingRulesName: databasesuffixname
    inboundDnsServerIPAddress: dnsResolver.outputs.inboundEndpointsIp
    forwardingRuleSetName: forwardingRuleSets.name
  }
  dependsOn: [
    forwardingRuleSets
  ]
}

module forwardingRules02 'Modules/forwardingRules.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: 'internalmonorailnet'
  params: {
    domainName: 'internal.monorail.net.'
    forwardingRulesName: 'internalmonorailnet'
    inboundDnsServerIPAddress: dnsResolver.outputs.inboundEndpointsIp
    forwardingRuleSetName: forwardingRuleSets.name
  }
  dependsOn: [
    forwardingRules01
  ]
}

module forwardingRules03 'Modules/forwardingRules.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: 'Wildcard'
  params: {
    domainName: '.'
    forwardingRulesName: 'Wildcard'
    inboundDnsServerIPAddress: '10.5.5.5'
    forwardingRuleSetName: forwardingRuleSets.name
  }
  dependsOn: [
    forwardingRules02
    forwardingRules01
  ]
}

module bastionNsg 'Modules/bastionnsg.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-AzureBastionHost-NSG'
  params: {
    bastionHostName: '${prefix}-AzureBastionHost'
    location: location
  }
  dependsOn:[
    cmpsubnet2
  ]
}

module bastionsn 'Modules/subnet-nsg.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-bastionsn'
  params: {
    subnetname: '${virtualNetwork.name}/AzureBastionSubnet'
    addressprefix: '${spoke01Address}${bastionSN}'
    nsgid: bastionNsg.outputs.bastionHostNSGId

  }
  dependsOn:[
    bastionNsg
    cmpsubnet2
  ]
}

module vpnsubnet 'Modules/subnet.bicep' = {
  scope: resourceGroup(connectRG.name)
  name: '${prefix}-vpnsn'
  params: {
    subnetname: '${virtualNetwork.name}/GatewaySubnet'
    addressprefix: '${spoke01Address}${vpnSN}'
  }
  dependsOn: [
    virtualNetwork
  ]
}

// VPN gateway
module vpngtw 'Modules/vpnGateway.bicep' = {
name: '${prefix}-vpnsngtw'
scope: resourceGroup(connectRG.name)
params:{
  location: location
  gatewayName: '${prefix}-vpnsngtw'
  gatewaySku: vpnGatewaySku
  privateIPAllocationMethod: 'Dynamic'
  subnetid: vpnsubnet.outputs.subnetid
  tenantId: tenantid
  vpnClientAddressCIDR: vpnClientAddressCIDR
  vpnClientProtocols: vpnClientProtocols
}
dependsOn: [
  vpnsubnet
  connectRG
]
}

// Virtual Machine
module compute01 'Modules/Compute.bicep' = {
  scope: resourceGroup(computeRG.name)
  name: '${prefix}-compute01'
  params: {
    adminPassword: 'Tuesday!323'
    imageOffer: imageOffer
    imageOSsku: imageOSSku
    imagePublisher: imagePublisher
    imageVersion: imageVersion
    location: location
    sakind: sakind
    storageAccountPrefix:prefix
    storageskuname: storageskuname
    subnetName: cmpsubnet2.name
    vmName: '${prefix}${vmName}01'
    vmSize: vmSize
    vNetName: virtualNetwork.name
    vnetrgname: connectRG.name
  }
  dependsOn:[
    cmpsubnet
  ]
}

module compute02 'Modules/Compute.bicep' = {
  scope: resourceGroup(computeRG.name)
  name: '${prefix}-compute02'
  params: {
    adminPassword: 'Tuesday!323'
    imageOffer: imageOffer
    imageOSsku: imageOSSku
    imagePublisher: imagePublisher
    imageVersion: imageVersion
    location: location
    sakind: sakind
    storageAccountPrefix:prefix
    storageskuname: storageskuname
    subnetName: cmpsubnet.name
    vmName: '${prefix}${vmName}02'
    vmSize: vmSize
    vNetName: virtualNetwork.name
    vnetrgname: connectRG.name
  }
  dependsOn:[
    cmpsubnet2
    compute01
  ]
}

// BastionHost

module bastionHost 'Modules/bastionhost.bicep' = {
  scope: resourceGroup(computeRG.name)
  name: '${prefix}Bastion'
  params: {
    domainNameLabel: toLower('${prefix}${label}')
    location: location
    publicIPAddressName: '${bastionHostName}-${prefix}'
    subnetid: bastionsn.outputs.subnetid
  }
  dependsOn:[
    bastionsn
  ]
}


output DNSServer string = dnsResolver.outputs.inboundEndpointsIp
