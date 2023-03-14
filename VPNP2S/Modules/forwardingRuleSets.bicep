param forwardRuleSetName string
param location string
param outboundEndpointsId string


resource forwardingRuleSets 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: forwardRuleSetName
  location: location
  properties: {
    dnsResolverOutboundEndpoints:  [
       {
        id: outboundEndpointsId
       }
    ]
  }
}


output id string = forwardingRuleSets.id
output name string = forwardingRuleSets.name
