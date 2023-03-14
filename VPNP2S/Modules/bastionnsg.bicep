param bastionHostName string
param location string

resource securityGroupName 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
  name: '${bastionHostName}-NSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInbound'
        properties: {
          description: 'Ingress Traffic from public internet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 210
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInbound'
        properties: {
          description: 'Ingress Traffic from Azure Bastion control plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 220
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          description: 'Ingress Traffic from Azure Load Balancer'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 230
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunications'
        properties: {
          description: 'Ingress Traffic from Azure Load Balancer'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
           destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 240
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          description: 'DenyAllInBound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
           destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1500
          direction: 'Inbound'
        }
      }

      {
        name: 'AllowSshRdpOutbound'
        properties: {
          description: 'Egress Traffic to target VMs'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 210
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudOutbound'
        properties: {
          description: 'Egress Traffic to Azure Bastion data plane'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 220
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionCommunication'
        properties: {
          description: 'Egress Traffic to other public endpoints in Azure'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]

          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 230
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformation'
        properties: {
          description: 'Egress Traffic to other public endpoints in Azure'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 240
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          description: 'DenyAllOutBound'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
           destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1500
          direction: 'Outbound'
        }
      }
    ]
  }
}

output bastionHostNSGId string = securityGroupName.id

