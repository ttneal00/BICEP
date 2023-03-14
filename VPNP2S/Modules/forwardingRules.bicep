param forwardingRulesName string
param domainName string
param inboundDnsServerIPAddress string
param forwardingRuleSetName string

resource forwardingRuleSet 'Microsoft.Network/dnsForwardingRulesets@2022-07-01'  existing = {
  name: forwardingRuleSetName
}

resource forwardingRules 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2022-07-01'  = {
  name: forwardingRulesName
  parent: forwardingRuleSet
  properties: {
    domainName: domainName
    targetDnsServers:  [
       {
        ipAddress: inboundDnsServerIPAddress
        port: 53
       }
    ]
    forwardingRuleState: 'Enabled'
  }
}

output id string = forwardingRules.id
output environmentOutput string = environment().suffixes.sqlServerHostname
