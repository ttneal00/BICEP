param remoteVnetName string
param localvnetId string
param localVnetName string
param useRemoteGateways bool 
param allowGatewayTransit bool
param allowForwardedTraffic bool 
param allowVirtualNetworkAccess bool = true

// @allowed([
//   'local'
//   'remote'
// ])
// param localorRemote string

resource vnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: remoteVnetName
}

resource vnetPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = {
  name: '${vnet.name}-to-${localVnetName}-peer'
  parent: vnet
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: localvnetId
    }
  }
}
