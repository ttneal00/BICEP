targetScope = 'resourceGroup'

param VnetId string
param vnetName string

param privateDnsZones array = [
  {
  name:  'privatelink${environment().suffixes.sqlServerHostname}'
  vnetId:VnetId
  }
  {
    name:  'privatelink.blob.${environment().suffixes.storage}'
    vnetId:VnetId
  }
  {
    name:'privatelink.dfs.${environment().suffixes.storage}'
    vnetId:VnetId
  }
  {
    name: 'privatelink.table.${environment().suffixes.storage}'
    vnetId:VnetId
  }
  {
    name: 'privatelink.vaultcore.azure.net'
    vnetId:VnetId
  }
  {
    name: 'privatelink.azuresynapse.net'
    vnetId:VnetId
  }
  {
    name: 'privatelink.sql.azuresynapse.net'
    vnetId:VnetId
  }
  {
    name:'privatelink.dev.azuresynapse.net'
    vnetId: VnetId
  }
  {
    name: 'privatelink.azurewebsites.net'
      vnetId: VnetId
  }
  {
    name: 'privatelink.servicebus.windows.net'
      vnetId: VnetId
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
      id: resourceId('Microsoft.Network/virtualNetworks',vnetName)
    }
  }
}]


// Module outputs

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

