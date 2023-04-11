param localVnetName string
param remoteVnetPeers array
param useRemoteGateways bool
param allowGatewayTransit bool
param allowForwardedTraffic bool 
param allowVirtualNetworkAccess bool = true

resource localvnet 'Microsoft.Network/virtualnetworks@2015-05-01-preview' existing = {
  name: localVnetName
}

resource vnetPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-07-01' = [for remotePeer in remoteVnetPeers: {
  name: '${localVnetName}-to-${remotePeer.vnetName}-peer'
  parent: localvnet
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: '/subscriptions/${remotePeer.subscription}/resourceGroups/${remotePeer.resourceGroup}/providers/Microsoft.Network/virtualNetworks/${remotePeer.vnetName}'
    }
  }
}]
