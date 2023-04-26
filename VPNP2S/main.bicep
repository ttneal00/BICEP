targetScope = 'subscription'
param prefix string
param location string
param tenantid string = subscription().tenantId
param globaltags object = {

}

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
param hub01Network string
param hubName string
param publicSubnet string
param supportSubnet string
param dnsResolverInboundSubnet string
param dnsResolverOutboundSubnet string
param vpnGatewaySubnet string
param computeSubnet string
param myIpAddress string

param defaultNsg string
param spoke01Prefix string = '${spoke01Network}0.0/16'
param hub01Prefix string = '${hub01Network}0.0/16'
param vpnClientAddressCIDR string
param vpnClientProtocols string
param vpnGatewaySku string

// dnsResolver Info
param dnsResolversuffix string
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

param networks array = [
  {
    name: '${prefix}-${hubName}-01'
    vnetPrefix: spoke01Prefix
    location: location
    scope: spokeRgName
    subnets: [
      {
        name: '${prefix}-${spokeName}-publicSn'
        properties:{
          addressPrefix: '${spoke01Network}${publicSubnet}'    
        }
        nsg:{
          id: resourceId('Microsoft.Network/networkSecurityGroups','${prefix}-${spokeName}-publicSn-defaultNsg')
          name: '${prefix}-${spokeName}-publicSn-nsg'
          securityRules: []
        }
      }
      {
        name: '${prefix}-${spokeName}-supportSn'
        properties:{
          addressPrefix: '${spoke01Network}${supportSubnet}'
    
        }
        nsg:{
          id: resourceId('Microsoft.Network/networkSecurityGroups','${prefix}-${spokeName}-supportSn-defaultNsg')
          name: '${prefix}-${spokeName}-supportSn-nsg'
          securityRules: []
        }
      }
      {
        name: '${prefix}-${spokeName}-dnsResolverInboundSn'
        subnetProperties:{
          addressPrefix: '${spoke01Network}${dnsResolverInboundSubnet}'
        }
        subnetDelegations: [
          {
            name: '${prefix}-${spokeName}-dnsResolverInboundSn-del'
            properties: {
            serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
        nsg:{
          id: resourceId('Microsoft.Network/networkSecurityGroups','${prefix}-${spokeName}-dnsResolverInboundSn-defaultNsg')
          name: '${prefix}-${spokeName}-dnsResolverInboundSn-nsg'
          securityRules: []
        }

        
      }
      {
        name: '${prefix}-${spokeName}-dnsResolverOutboundSn'
        properties:{
          addressPrefix: '${spoke01Network}${dnsResolverOutboundSubnet}'
        }
        subnetDelegations: [
          {
            name: '${prefix}-${spokeName}-dnsResolverOutboundSn-del'
            properties: {
              serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
        nsg:{
          id: resourceId('Microsoft.Network/networkSecurityGroups','${prefix}-${spokeName}-dnsResolverOutboundSn-defaultNsg')
          name: '${prefix}-${spokeName}-dnsResolverOutboundSn-nsg'
          securityRules: []
        }
        
      }
      {
        name: 'GatewaySubnet'
        properties:{
          addressPrefix: '${spoke01Network}${vpnGatewaySubnet}'
        }
        nsg:{
          id: resourceId('Microsoft.Network/networkSecurityGroups','${prefix}-${spokeName}-GatewaySubnet-defaultNsg')
          name: '${prefix}-${spokeName}-GatewaySubnet-nsg'
          securityRules: []
        }
      }
    ]
   
  }
  {
    name: '${prefix}-${spokeName}-01'
    vnetPrefix: hub01Prefix
    location: location
    scope: spokeRgName
    subnets: [
      {
        name: '${spokeName}-computeSn'
        properties:{
          addressPrefix: '${spoke01Network}${computeSubnet}'
        }
        nsg:{
          id: resourceId('Microsoft.Network/networkSecurityGroups','${prefix}-${spokeName}-GatewaySubnet-defaultNsg')
          name: '${prefix}-${spokeName}-compute-nsg'
          securityRules: [
            {
              name: 'AllowRDPInbound'
              properties: {
                protocol: 'TCP'
                sourcePortRange: '*'
                destinationPortRange: '3389'
                sourceAddressPrefix: myIpAddress
                destinationAddressPrefix: '*'
                access: 'Allow'
                priority: 'Inbound'
              }
            }
          ]
        }
      }
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
module virtualNetwork 'Modules/Network/network.bicep' =[for (network, i) in networks:{
  scope: resourceGroup(connectRgName)
  name: '${network.name}'
  params: {
    location: location
    vnetAddress: network.vnetPrefix
    vnetName: '${network.name}'
    subnets: network.subnets
    tags: globaltags
   }
  dependsOn:[
    resourceGroupLoop
    nsgModule
  ]
}]

module nsgModule 'Modules/Network/nsgDefault.bicep' = [for (item, i) in networks:{
  scope:  resourceGroup(connectRgName)
  name: item.subnets.nsgName
  params: {
    location: item.location
    nsgName: item.subnets.nsgName
    securityRules: item.nsg.securityRules
  }
  dependsOn: [
    resourceGroupLoop
  ]
}]

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
