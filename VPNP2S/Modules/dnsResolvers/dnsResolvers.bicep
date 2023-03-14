param location string
param dnsResolvercfgname string
param virtualNetworkId string
param inboundEndpointsName string
param inboundSubnetId string
param outboundSubnetId string
param outboundEndpointsName string

resource dnsResolvercfg 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: dnsResolvercfgname
  location: location
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }

}

resource inboundEndpoints 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  name: inboundEndpointsName
  parent: dnsResolvercfg
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: inboundSubnetId
        }
      }
    ]
  }
}

resource outboundEndpoints 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  name: outboundEndpointsName
  parent: dnsResolvercfg
  location: location
  properties: {
    subnet: {
      id: outboundSubnetId
    }
  }
}

output inboundEndpointsIp string = inboundEndpoints.properties.ipConfigurations[0].privateIpAddress
output dnsresolverId string = dnsResolvercfg.id
output outboundEndpointId string = outboundEndpoints.id
