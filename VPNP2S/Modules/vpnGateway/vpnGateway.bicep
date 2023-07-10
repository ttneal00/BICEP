param location string
param tenantId string 
param gatewayName string
param vpnClientAddressCIDR string
param tags object

@allowed([
  'Static'
  'Dynamic'
])
param privateIPAllocationMethod string


@description('Route based (Dynamic Gateway) or Policy based (Static Gateway)')
@allowed([
  'RouteBased'
  'PolicyBased'
])
param vpnType string = 'RouteBased'

@description('The SKU of the Gateway. This must be either Standard or HighPerformance to work with OpenVPN')
@allowed([
  'Basic'
  'Standard'
  'HighPerformance'
])
param gatewaySku string

param subnetid string
@allowed([
  'Vpn'
  'ExpressRoute'
  'LocalGateway'
])
param gatewayType string = 'Vpn'


@allowed([
  'IkeV2'
  'OpenVPN'
  'SSTP'
])
param vpnClientProtocols string = 'OpenVPN'


@allowed([
  'AAD'
  'Certificate'
  'Radius'
])
param vpnAuthenticationTypes string = 'AAD'

@description('The Application ID of the "Azure VPN" Azure AD Enterprise App.')
var audienceMap = {
  AzureCloud: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
  AzureUSGovernment: '51bb15d4-3a4f-4ebf-9dca-40096fe32426'
  AzureGermanCloud: '538ee9e6-310a-468d-afef-ea97365856a9'
  AzureChinaCloud: '49f817b6-84ae-4cc0-928c-73f27289b3aa'
}

var cloud = environment().name

var audience = audienceMap[cloud]

var issuer = 'https://sts.windows.net/${tenantId}/'
var tenant = uri(environment().authentication.loginEndpoint, tenantId)


resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${gatewayName}Pip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: gatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: subnetid
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
        name: '${gatewayName}Config'
      }
    ]
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    gatewayType: gatewayType
    vpnType: vpnType
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          vpnClientAddressCIDR
        ]
      }
      vpnClientProtocols: [
        vpnClientProtocols
      ]
      vpnAuthenticationTypes: [
        vpnAuthenticationTypes
      ]
      aadTenant: tenant
      aadAudience: audience
      aadIssuer: issuer
    }
  }
  tags: tags
}

