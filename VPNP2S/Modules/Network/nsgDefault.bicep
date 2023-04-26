param location string
param nsgName string
param securityRules object

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [securityRules]
  }
}

output id string = nsg.id
output name string = nsg.name
