param environmentPrefix string
param globalTags object = {
      Environment: 'lab'
      Location: 'location'
      Last_Modified: utcNow('d')
      }
param location string
param servicebusName string
param zoneRedundant bool = false
param disabledLocalAuth bool = false
param minimumTlsVersion string = '1.2'
param premiumMessagingPartitions int = 0
param publicNetworkAccess string = 'enabled'
param serviceBusSku string = 'Standard'

module servicebus 'Modules/servicebus.bicep' = {
  name: '${servicebusName}-${environmentPrefix}'
  params: {
    globalTags: globalTags
    location: location
    serviceBusName: servicebusName
    disabledLocalAuth: disabledLocalAuth
    zoneRedundant: zoneRedundant
    minimumTlsVersion: minimumTlsVersion
    premiumMessagingPartitions: premiumMessagingPartitions
    publicNetworkAccess: publicNetworkAccess
    serviceBusSku: serviceBusSku
  }
}
