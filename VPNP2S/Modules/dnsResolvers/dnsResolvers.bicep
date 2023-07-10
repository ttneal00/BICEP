param location string
param dnsResolvercfgname string
param virtualNetworkId string
param inboundEndpointsName string
param inboundSubnetId string
param outboundSubnetId string
param outboundEndpointsName string
param tags object

resource dnsResolvercfg 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: dnsResolvercfgname
  location: location
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  tags: tags
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

// module ruleSet 'forwardingRuleSets.bicep' = {
//   name: '${dnsResolvercfgname}-fwruleset'
//   params: {
//     forwardRuleSetName: '${dnsResolvercfgname}-fwruleset'
//     location: location
//     outboundEndpointsId: outboundEndpoints.id
//   }
// }

output inboundEndpointsIp string = inboundEndpoints.properties.ipConfigurations[0].privateIpAddress
output dnsresolverId string = dnsResolvercfg.id
output outboundEndpointId string = outboundEndpoints.id
