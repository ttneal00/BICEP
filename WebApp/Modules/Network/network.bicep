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
param datasvcSubnetPrefix string
param datasvcSubnetName string
param computeSubnetPrefix string
param computeSubnetName string
param appVnetIntSubnetPrefix string
param appVnetIntSubnetName string
param globaltags object
param environmentLabel string

param nsgNames array = [
  'nsgapp-${environmentLabel}01'
  'nsgsharedsvc-${environmentLabel}01'
  'nsgdbst-${environmentLabel}01'
  'nsgvnetint-${environmentLabel}01'
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
    name: datasvcSubnetName
    properties: {
      addressPrefix: datasvcSubnetPrefix
      networkSecurityGroup: {
        id: defaultNsg[2].outputs.id
      }
    }
  }
  {
   name: computeSubnetName
   properties: {
    addressPrefix: computeSubnetPrefix
    networkSecurityGroup: {
      id: defaultNsg[0].outputs.id
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

  {
    name: appVnetIntSubnetName
    properties: {
      addressPrefix: appVnetIntSubnetPrefix
      networkSecurityGroup: {
        id: defaultNsg[3].outputs.id
      }
      delegations: [
        {
          name: '${appVnetIntSubnetName}-del'
          properties: {
            serviceName: 'Microsoft.Web/serverfarms'
          }
        }
      ]
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

output datasvcSubnetID string = vnet.properties.subnets[1].id
output datasvcSubnetName string = vnet.properties.subnets[1].name
output datasvcSubnetPrefix string = vnet.properties.subnets[1].properties.addressPrefix

output computeSubnetID string = vnet.properties.subnets[2].id
output computeSubnetName string = vnet.properties.subnets[2].name
output computeSubnetPrefix string = vnet.properties.subnets[2].properties.addressPrefix

output supportServicvesSubnetId string = vnet.properties.subnets[3].id
output supportServicvesSubnetName string = vnet.properties.subnets[3].name
output supportServicvesSubnetPrefix string = vnet.properties.subnets[3].properties.addressPrefix

output appVnetIntSubnetID string = vnet.properties.subnets[4].id
output appVnetIntSubnetName string = vnet.properties.subnets[4].name
output appVnetIntSubnetPrefix string = vnet.properties.subnets[4].properties.addressPrefix

