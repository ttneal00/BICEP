targetScope = 'subscription'

param resourceGroupName string
param location string
param tags object

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}
