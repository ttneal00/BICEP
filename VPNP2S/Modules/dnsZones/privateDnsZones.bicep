targetScope = 'resourceGroup'

param vpnVnetId string

param privateDnsZones array = [
  {
  name:  'privatelink${environment().suffixes.sqlServerHostname}'
  vnetId:vpnVnetId
  }
  {
    name:  'privatelink.blob.${environment().suffixes.storage}'
    vnetId:vpnVnetId
  }
  {
    name:'privatelink.dfs.${environment().suffixes.storage}'
    vnetId:vpnVnetId
  }
  {
    name: 'privatelink.table.${environment().suffixes.storage}'
    vnetId:vpnVnetId
  }
  {
    name: 'privatelink.vaultcore.azure.net'
    vnetId:vpnVnetId
  }
  {
    name: 'privatelink.azuresynapse.net'
    vnetId:vpnVnetId
  }
  {
    name: 'privatelink.sql.azuresynapse.net'
    vnetId:vpnVnetId
  }
  {
    name:'privatelink.dev.azuresynapse.net'
    vnetId: vpnVnetId
  }
  {
    name: 'privatelink.azurewebsites.net'
      vnetId: vpnVnetId
  }
  {
    name: 'privatelink.servicebus.windows.net'
      vnetId: vpnVnetId
  }
 ]


 param itemCount int = length(privateDnsZones)
// param vnetIds array

resource prvDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' = [for privateDnsZone in privateDnsZones:{
  name: privateDnsZone.name
  location: 'global'
}]

resource dnsVirtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for i in range(0, itemCount) :{
  name: '${prvDnsZones[i].name}link'
  parent: prvDnsZones[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork:  {
      id: privateDnsZones[i].vnetId
    }
  }
}]


// Module outputs

output zones array = [for (zone, i) in privateDnsZones:{
  privateZoneName: prvDnsZones[i].name
  privateZoneId: privateDnsZones[i].id
}]

output sqlDnsZoneName string = prvDnsZones[0].name
output sqlDnsZoneId string = prvDnsZones[0].id

output blobDnsZoneName string = prvDnsZones[1].name
output blobDnsZoneId string = prvDnsZones[1].id

output dfsDnsZoneName string = prvDnsZones[2].name
output dfsDnsZoneId string = prvDnsZones[2].id

output tableDnsZoneName string = prvDnsZones[3].name
output tableDnsZoneId string = prvDnsZones[3].id

output keyVaultDnsZoneName string = prvDnsZones[4].name
output keyVaultDnsZoneId string = prvDnsZones[4].id

output synapseWebDnsZoneName string = prvDnsZones[5].name
output synapseWebDnsZoneId string = prvDnsZones[5].id

output sqlSynapseWebDnsZoneName string = prvDnsZones[6].name
output sqlSynapseWebDnsZoneId string = prvDnsZones[6].id

output devSynapseWebDnsZoneName string = prvDnsZones[7].name
output devSynapseWebDnsId string = prvDnsZones[7].id

output WebAppDnsZoneName string = prvDnsZones[8].name
output WebAppDnsId string = prvDnsZones[8].id

output serviceBusDnsZoneName string = prvDnsZones[9].name
output serviceBusDnsId string = prvDnsZones[9].id

