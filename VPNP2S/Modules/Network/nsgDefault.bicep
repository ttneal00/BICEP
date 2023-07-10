param location string
param nsgName string

resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
}

output id string = networkSecurityGroups.id


