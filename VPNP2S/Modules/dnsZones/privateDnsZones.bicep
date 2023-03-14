param vnetId string
param vnetName string
param sharedsubcriptionId string
param dnsResourceGroupName string

param privateDnsZones array = [
  {
  name:  'privatelink${environment().suffixes.sqlServerHostname}'
  }
  {
    name:  'privatelink.blob.${environment().suffixes.storage}'
  }
  {
    name:'privatelink.dfs.${environment().suffixes.storage}'
  }
  {
    name: 'privatelink.table.${environment().suffixes.storage}'
  }
  {
    name: 'privatelink.vaultcore.azure.net'
  }
  {
    name: 'privatelink.azuresynapse.net'
  }
  {
    name: 'privatelink.sql.azuresynapse.net'
  }
  {
    name:'privatelink.dev.azuresynapse.net'
  }
  {
    name: 'privatelink.azurewebsites.net'
  }
 ]

// Resource Deployment

// param itemCount int = length(privateDnsZones)

module virtualNetorkLink 'dnsVirtualNetworkLink.bicep' = [for privateDnsZone in privateDnsZones:  {
  scope: resourceGroup(sharedsubcriptionId,dnsResourceGroupName )
  name: privateDnsZone
  params: {
    registrationEnabled: false
    vnetId: vnetId
    vnetName:vnetName
  }
}]
