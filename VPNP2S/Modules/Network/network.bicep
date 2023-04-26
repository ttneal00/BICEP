targetScope = 'resourceGroup'

//
// Parameters and Vars
//
param location string
param vnetName string 
param vnetAddress string
param tags object
param subnets object

//
// Deployments
//

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }

 subnets: [subnets]
    
  }
tags: tags

}

output vnetid string = vnet.id
output subnetsArray array = vnet.properties.subnets
output vnetAddressPrefix array = vnet.properties.addressSpace.addressPrefixes


// output vnetAddressSpace string = vnet.properties.addressSpace.addressPrefixes[0]

// output publicSubnetID string = vnet.properties.subnets[0].id
// output publicSubnetName string = vnet.properties.subnets[0].name
// output publicSubnetPrefix string = vnet.properties.subnets[0].properties.addressPrefix

// output sharedsvcSubnetId string = vnet.properties.subnets[1].id
// output sharedsvcSubnetName string = vnet.properties.subnets[1].name
// output sharedsvcSubnetPrefix string = vnet.properties.subnets[1].properties.addressPrefix

// output datasvcSubnetID string = vnet.properties.subnets[2].id
// output datasvcSubnetName string = vnet.properties.subnets[2].name
// output datasvcSubnetPrefix string = vnet.properties.subnets[2].properties.addressPrefix

// output appsvcSubnetID string = vnet.properties.subnets[3].id
// output appsvcSubnetName string = vnet.properties.subnets[3].name
// output appsvcSubnetPrefix string = vnet.properties.subnets[3].properties.addressPrefix

// output dnsResolverInboundSubnetID string = vnet.properties.subnets[4].id
// output dnsResolverInboundSubnetName string = vnet.properties.subnets[4].name
// output dnsResolverInboundSubnetPrefix string = vnet.properties.subnets[4].properties.addressPrefix

// output dnsResolverOutboundSubnetID string = vnet.properties.subnets[5].id
// output dnsResolverOutboundSubnetName string = vnet.properties.subnets[5].name
// output dnsResolverOutboundSubnetPrefix string = vnet.properties.subnets[5].properties.addressPrefix

// output appVnetIntHostID string = vnet.properties.subnets[6].id
// output appVnetIntHostName string = vnet.properties.subnets[6].name
// output appVnetIntHostPrefix string = vnet.properties.subnets[6].properties.addressPrefix
