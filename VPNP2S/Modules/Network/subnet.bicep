param nsgArray array
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}

resource subnetdelegation 'Microsoft.Network/virtualNetworks/subnets@2022-09-01'  =[for (nsg, i) in nsgArray: {
  name: nsg.subnetName
  parent: vnet
  properties: {
    addressPrefix: nsg.subnetAddressPrefix
    networkSecurityGroup:{
      id: nsg.id
    }
    delegations: [
      {
        name: '${nsg.subnetName}-del'
        properties: {
          serviceName: nsg.subnetDelegrations
        }
      }
    ]
  }
}]

