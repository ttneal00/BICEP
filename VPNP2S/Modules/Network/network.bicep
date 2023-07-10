targetScope = 'resourceGroup'

//
// Parameters and Vars
//

param location string
param vnetName string 
param vnetAddress string
param publicSubnetName string
param publicAddressPrefix string
param supportServicvesSubnetName string
param supportServicvesSubnetPrefix string
param computeSubnetPrefix string
param computeSubnetName string
param tags object
param dnsResolverInboundSubnetPrefix string
param dnsResolverInboundSubnetName string
param dnsResolverOutboundSubnetPrefix string
param dnsResolverOutboundSubnetName string
param vnetIntegrationSubnetName string
param vnetIntegrationSubnetPrefix string 
param VPNGatewaySubnetPrefix string

//
// Deployments
//

module nsg 'nsgDefault.bicep' = {
  name: 'DefaultNSG'
  params: {
    location: location
    nsgName: 'DefaultNSG'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  tags: tags
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
      networkSecurityGroup: {
        id: nsg.outputs.id
      }

    }
  }
  {
   name: computeSubnetName
   properties: {
    addressPrefix: computeSubnetPrefix
    networkSecurityGroup: {
      id: nsg.outputs.id
    }
   } 
  
  } 
  {
    name: supportServicvesSubnetName
    properties: {
     addressPrefix: supportServicvesSubnetPrefix
     networkSecurityGroup: {
      id: nsg.outputs.id
    }
     delegations: []
    } 
  } 

  {
    name: dnsResolverInboundSubnetName
    properties: {
      addressPrefix: dnsResolverInboundSubnetPrefix
      networkSecurityGroup: {
        id: nsg.outputs.id
      }
      delegations: [
        {
          name: '${dnsResolverInboundSubnetName}-del'
          properties: {
            serviceName: 'Microsoft.Network/dnsResolvers'
          }
        }
      ]
    }
  }
  {
    name: dnsResolverOutboundSubnetName
    properties: {
      addressPrefix: dnsResolverOutboundSubnetPrefix
      networkSecurityGroup: {
        id: nsg.outputs.id
      }
      delegations: [
        {
          name: '${dnsResolverOutboundSubnetName}-del'
          properties: {
            serviceName: 'Microsoft.Network/dnsResolvers'
          }
        }
      ]
    }
  }
  {
    name: vnetIntegrationSubnetName
    properties: {
     addressPrefix: vnetIntegrationSubnetPrefix
     networkSecurityGroup: {
      id: nsg.outputs.id
    }
     delegations: [
      {
        name:'${vnetIntegrationSubnetName}-del'
        properties: {
          serviceName:  'Microsoft.Web/serverFarms'
        }
      }
     ]
    } 
  } 
    {
    name: 'GatewaySubnet'
    properties: {
     addressPrefix: VPNGatewaySubnetPrefix
     delegations: []
    } 
  } 
 ]
    
  }
}

output vnetid string = vnet.id
output vnetAddressSpace string = vnet.properties.addressSpace.addressPrefixes[0]

output subnets array = vnet.properties.subnets

output publicSubnetID string = vnet.properties.subnets[0].id
output publicSubnetName string = vnet.properties.subnets[0].name
output publicSubnetPrefix string = vnet.properties.subnets[0].properties.addressPrefix

output datasvcSubnetID string = vnet.properties.subnets[1].id
output datasvcSubnetName string = vnet.properties.subnets[1].name
output datasvcSubnetPrefix string = vnet.properties.subnets[1].properties.addressPrefix

output computeSubnetID string = vnet.properties.subnets[2].id
output computeSubnetName string = vnet.properties.subnets[2].name
output computeSubnetPrefix string = vnet.properties.subnets[2].properties.addressPrefix

output supportServicvesSubnetId string = vnet.properties.subnets[3].id
output supportServicvesSubnetName string = vnet.properties.subnets[3].name
output supportServicvesSubnetPrefix string = vnet.properties.subnets[3].properties.addressPrefix
