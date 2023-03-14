param registrationEnabled bool
param vnetId string
param vnetName string

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
