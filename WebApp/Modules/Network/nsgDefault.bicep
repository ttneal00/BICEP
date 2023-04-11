param location string
param nsgName string

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
}

output id string = nsg.id
output name string = nsg.name
