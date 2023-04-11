param  privateEndpointName string
param  subnetId string
param  privateLinkServiceId string
param  location string
param  groupId string
param pvtEndpointDnsGroupName string
param privateDnsZoneId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {

    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            groupId
          ]
          privateLinkServiceConnectionState: {
            actionsRequired: 'None'
            status: 'Approved'
          }

        }
      
      }
    ]
    customNetworkInterfaceName: '${privateEndpointName}-nic'
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: pvtEndpointDnsGroupName
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    
  ]
}

output peId string = privateEndpoint.id
output penetworkInterfaceId string = privateEndpoint.properties.networkInterfaces[0].id
output peFqdn array = privateEndpoint.properties.customDnsConfigs
// output peIP string = privateEndpoint.properties.ipConfigurations[0].properties.privateIPAddress
// output peIP2 string = privateEndpoint.properties.networkInterfaces[0].properties.ipConfigurations[0].properties.privateIPAddress
