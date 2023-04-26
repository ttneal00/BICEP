param registrationEnabled bool
param vnetId string
param vnetName string

param privateDnsZones array

resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for privateDnsZone in privateDnsZones:{
  name: '${privateDnsZone.name}/${vnetName}-link'
  location: 'global'
  properties:{
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: vnetId
    }
  }
}]
