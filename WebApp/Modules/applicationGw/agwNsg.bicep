param location string 
param agwSecurityGroupName string

// $apimRule1 = New-AzNetworkSecurityRuleConfig -Name apim-in -Description "APIM inbound" `
//     -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 -SourceAddressPrefix `
//     ApiManagement -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 3443
// $apimNsg = New-AzNetworkSecurityGroup -ResourceGroupName $resGroupName -Location $location -Name `
//     "NSG-APIM" -SecurityRules $apimRule1

resource securityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: agwSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'appgw-in'
        properties: {
          description: 'AppGw inbound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'appgw-in-internet'
        properties: {
          description: 'AppGw inbound Internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgid string = securityGroupName_resource.id
