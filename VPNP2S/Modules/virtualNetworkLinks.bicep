param virtualNetworkId string
param virtualNetworkLinkName string
param forwardingRulesetName string

resource forwardingRules 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' existing = {
  name: forwardingRulesetName
}

resource virtualNetworkLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  name: virtualNetworkLinkName
  parent: forwardingRules
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}
