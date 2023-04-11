
param arecordName string
param dnsZoneName string
param ipv4Address string

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: dnsZoneName
}

resource aRecordDns 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: arecordName
  parent: dnsZone
  properties: {
    aRecords: [
      {
        ipv4Address: ipv4Address
      }
    ]
  }
  


}

output aRecordFqdn string = aRecordDns.name
