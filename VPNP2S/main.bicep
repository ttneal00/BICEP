targetScope = 'subscription'
param prefix string
param location string
param tenantid string = subscription().tenantId



// Enviornment

var databasesuffix = environment().suffixes.sqlServerHostname
var databasesuffixname = replace(databasesuffix, '.','')


// Resource Group Vars and Params
param connectRgName string
param spokeRgName string = '${prefix}${spokeName}-${connectRgName}'
param hubRgName string  = '${prefix}${hubName}-${connectRgName}'
param computeRgName string


// virtual network vars and params
param spokeName string
param spoke01Network string
param hub01Address string
param hubName string
param subnet01 string
param subnet02 string
param vpnSN string
var spoke01Prefix = '${spoke01Network}0.0/16'
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

var resourceGroups = [
  {
    name: spokeRgName
    location: location
  }
  {
    name: hubRgName
    location: location
  }
  {
    name: computeRgName
    location: location 
  }
]

var networks = [
  {
    name: spokeName
    vnetPrefix: spoke01Prefix
    location: location
    scope: spokeRgName
    subnets: [
      {
        name: 'publicSn-${spokeName}'
        properties:{
          addressPrefix: '${spoke01Network}0.0/24'
    
        }
      }
      {
        name: 'supportSn-${spokeName}'
        properties:{
          addressPrefix: '${spoke01Network}10.0/24'
    
        }
      }
    ]
  }
  {
    name: hubRgName
    location: location
    vnetPrefix: hub01Address
    scope: hubRgName
    subnets:[
      
    ]
  }
]

// Resource Group Modules
module resourceGroupLoop 'Modules/ResourceGroup.bicep' =[for resourceGroup in resourceGroups: {
  name: resourceGroup.name
  params: {
    location: location
    resourceGroupName: '${prefix}${connectRgName}'
  }
}]


//Connect Modules
module virtualNetwork 'Modules/Network/network.bicep' = {
  scope: resourceGroup(connectRgName)
  name: '${prefix}${spokeName}-01'
  params: {
    location: location
    vnetAddress: spoke01CIDR
    vnetName: '${prefix}${spokeName}-01'
    subnets: networks.subnets
    `
  }
  dependsOn:[
    resourceGroupLoop
  ]
}

// module dnsResolverIbSn 'Modules/subnet.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: '${prefix}-dnsResolverIbsn'
//   params: {
//     subnetname: '${virtualNetwork.name}/${prefix}-dnsResolverIbsn'
//     addressprefix: '${spoke01Address}${dnsResolverInboundSn}'
//   }
//   dependsOn:[
    
//   ]
// }

// module dnsResolverObSn 'Modules/subnet.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: '${prefix}-dnsResolverObsn'
//   params: {
//     subnetname: '${virtualNetwork.name}/${prefix}-dnsResolverObsn'
//     addressprefix: '${spoke01Address}${dnsResolverOutboundSn}'
//   }
//   dependsOn:[
//     dnsResolverIbSn
    
//   ]
// }
// module dnsResolver 'Modules/dnsResolvers/dnsResolvers.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: dnsResolverName
//   params: {
//     inboundEndpointsName: inboundEndpointsName
//     inboundSubnetId: dnsResolverIbSn.outputs.subnetid
//     location: location
//     outboundEndpointsName: outboundEndpointsName
//     outboundSubnetId: dnsResolverObSn.outputs.subnetid
//     virtualNetworkId: virtualNetwork.outputs.id
//     dnsResolvercfgname: dnsResolverName
//   }
// }

// module forwardingRuleSets 'Modules/forwardingRuleSets.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: forwardingRuleSetsName
//   params: {
//     forwardRuleSetName: forwardingRuleSetsName
//     location: location
//     outboundEndpointsId: dnsResolver.outputs.outboundEndpointId
//   }
// }

// module forwardingRules01 'Modules/forwardingRules.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: databasesuffixname
//   params: {
//     domainName: 'privatelink${databasesuffix}.'
//     forwardingRulesName: databasesuffixname
//     inboundDnsServerIPAddress: dnsResolver.outputs.inboundEndpointsIp
//     forwardingRuleSetName: forwardingRuleSets.name
//   }
//   dependsOn: [
//     forwardingRuleSets
//   ]
// }

// module forwardingRules02 'Modules/forwardingRules.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: 'internalmonorailnet'
//   params: {
//     domainName: 'internal.monorail.net.'
//     forwardingRulesName: 'internalmonorailnet'
//     inboundDnsServerIPAddress: dnsResolver.outputs.inboundEndpointsIp
//     forwardingRuleSetName: forwardingRuleSets.name
//   }
//   dependsOn: [
//     forwardingRules01
//   ]
// }

// module forwardingRules03 'Modules/forwardingRules.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: 'Wildcard'
//   params: {
//     domainName: '.'
//     forwardingRulesName: 'Wildcard'
//     inboundDnsServerIPAddress: '10.5.5.5'
//     forwardingRuleSetName: forwardingRuleSets.name
//   }
//   dependsOn: [
//     forwardingRules02
//     forwardingRules01
//   ]
// }

// module vpnsubnet 'Modules/subnet.bicep' = {
//   scope: resourceGroup(connectRG.name)
//   name: '${prefix}-vpnsn'
//   params: {
//     subnetname: '${virtualNetwork.name}/GatewaySubnet'
//     addressprefix: '${spoke01Address}${vpnSN}'
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// // VPN gateway
// module vpngtw 'Modules/vpnGateway.bicep' = {
// name: '${prefix}-vpnsngtw'
// scope: resourceGroup(connectRG.name)
// params:{
//   location: location
//   gatewayName: '${prefix}-vpnsngtw'
//   gatewaySku: vpnGatewaySku
//   privateIPAllocationMethod: 'Dynamic'
//   subnetid: vpnsubnet.outputs.subnetid
//   tenantId: tenantid
//   vpnClientAddressCIDR: vpnClientAddressCIDR
//   vpnClientProtocols: vpnClientProtocols
// }
// dependsOn: [
//   vpnsubnet
//   connectRG
// ]
// }
// output DNSServer string = dnsResolver.outputs.inboundEndpointsIp
