targetScope = 'resourceGroup'

param location string
param vnetName string 
param vnetAddress string

//subnet variables

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    } 
  }
}


output id string = vnet.id
output prefixes string = vnet.properties.addressSpace.addressPrefixes[0]
