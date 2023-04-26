targetScope = 'resourceGroup'

//
// Parameters and Vars
//
param location string
param vnetName string 
param vnetAddress string
param publicSubnetName string = '${vnetName}-pubsn'
param publicAddressPrefix string
param supportServicvesSubnetName string = '${vnetName}-supportsn'
param supportServicvesSubnetPrefix string
param computesvcSubnetPrefix string
param computeSubnetName string = '${vnetName}-computesn'
param globaltags object
param environmentPrefix string
param subnets object

param nsgNames array = [
  'nsgapp-${environmentPrefix}01'
  'nsgsharedsvc-${environmentPrefix}01'
  'nsgdbst-${environmentPrefix}01'
  'nsgvnetint-${environmentPrefix}01'
]

//
// Deployments
//

module defaultNsg 'nsgDefault.bicep' = [for nsgName in nsgNames:{
  name: nsgName
  params: {
    nsgName: nsgName
    location: location
  }
}]

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }

 subnets: [
  {
    name: publicSubnetName
    properties:{
      addressPrefix: publicAddressPrefix

    }
  }
  {
    name: computeSubnetName
    properties: {
      addressPrefix: computesvcSubnetPrefix
      networkSecurityGroup: {
        id: defaultNsg[2].outputs.id
      }
    }
  }
  {
    name: supportServicvesSubnetName
    properties: {
     addressPrefix: supportServicvesSubnetPrefix
     networkSecurityGroup: {
       id: defaultNsg[0].outputs.id
     }
     delegations: []
    } 
  } 
]
    
  }
tags: globaltags

}

output vnetid string = vnet.id
output vnetAddressSpace string = vnet.properties.addressSpace.addressPrefixes[0]

output publicSubnetID string = vnet.properties.subnets[0].id
output publicSubnetName string = vnet.properties.subnets[0].name
output publicSubnetPrefix string = vnet.properties.subnets[0].properties.addressPrefix

output sharedsvcSubnetId string = vnet.properties.subnets[1].id
output sharedsvcSubnetName string = vnet.properties.subnets[1].name
output sharedsvcSubnetPrefix string = vnet.properties.subnets[1].properties.addressPrefix

output datasvcSubnetID string = vnet.properties.subnets[2].id
output datasvcSubnetName string = vnet.properties.subnets[2].name
output datasvcSubnetPrefix string = vnet.properties.subnets[2].properties.addressPrefix

output appsvcSubnetID string = vnet.properties.subnets[3].id
output appsvcSubnetName string = vnet.properties.subnets[3].name
output appsvcSubnetPrefix string = vnet.properties.subnets[3].properties.addressPrefix

output dnsResolverInboundSubnetID string = vnet.properties.subnets[4].id
output dnsResolverInboundSubnetName string = vnet.properties.subnets[4].name
output dnsResolverInboundSubnetPrefix string = vnet.properties.subnets[4].properties.addressPrefix

output dnsResolverOutboundSubnetID string = vnet.properties.subnets[5].id
output dnsResolverOutboundSubnetName string = vnet.properties.subnets[5].name
output dnsResolverOutboundSubnetPrefix string = vnet.properties.subnets[5].properties.addressPrefix

output appVnetIntHostID string = vnet.properties.subnets[6].id
output appVnetIntHostName string = vnet.properties.subnets[6].name
output appVnetIntHostPrefix string = vnet.properties.subnets[6].properties.addressPrefix
