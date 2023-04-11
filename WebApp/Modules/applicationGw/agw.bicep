targetScope = 'resourceGroup'

param applicationGatewayName string
param location string
param tags object
param appGwManagedIdentityName string
// param akvName string
param sharedKvRGName string
param sharedkeyVaultName string
param sharedSubscriptionId string
param wildcardCertName string
param subnetId string
param rgAgwRgname string
param appDeploymentArray array

@allowed([
  'Standard_v2'
  'WAF_v2'
])
param apwskuname string = 'Standard_v2'

// Application Gateway Vars and Params
param applicationGatewaySubnetId string
param backendHttpSettingsCollectionPickHostNameFromBackendAddress bool = true
param backendHttpSettingsCollectionRequestTimeout int = 30
param enableHttp2 bool = true

@allowed([
  'Disabled'
  'Enabled'
])
param backendHttpSettingsCollectionCookieBasedAffinity string = 'Disabled'

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: sharedkeyVaultName
  scope: resourceGroup(sharedSubscriptionId,sharedKvRGName)
}

var keyVaultCertId = '${kv.properties.vaultUri}secrets/${wildcardCertName}'

resource applicationGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${applicationGatewayName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource agwId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: appGwManagedIdentityName
  location: location
}

resource applicateGateway 'Microsoft.Network/applicationGateways@2022-07-01' = {
  name: applicationGatewayName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${agwId.id}' : {}
    }
  }
  location: location
  tags: tags
  properties: {
    sku: {
      name: apwskuname
      tier: apwskuname
    }
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 10
    }
    enableHttp2: enableHttp2
    gatewayIPConfigurations: [
      {
        name: '${applicationGatewayName}-ipconfig'
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }

    ]
    sslCertificates: [
      {
        name: wildcardCertName
         properties: {
          keyVaultSecretId: keyVaultCertId
         }
      }
    ]
    frontendIPConfigurations: [
      {
        name: '${applicationGatewayName}-fepubip'
        properties: {
        publicIPAddress: {
          id: applicationGatewayPublicIp.id
        }
       privateIPAllocationMethod: 'Dynamic'
        privateLinkConfiguration: {

          id: '${subscription().id}/resourceGroups/${rgAgwRgname}/providers/Microsoft.Network/applicationGateways/${applicationGatewayName}/privateLinkConfigurations/pl${applicationGatewayName}'
          
        }
        }
      }
    ]
    frontendPorts: [
      {
        name: '${applicationGatewayName}-feports'
        properties: {
           port: 80
        }
      
      }
      {
        name: '${applicationGatewayName}-https'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: '${applicationGatewayName}-bePool'
        properties: {
          backendAddresses:[
            {
              fqdn: '${appDeploymentArray[0].name}.azurewebsites.net'
            }
            {
              fqdn: '${appDeploymentArray[1].name}.azurewebsites.net'
            }
            {
              fqdn: '${appDeploymentArray[2].name}.azurewebsites.net'
            }
            {
              fqdn: '${appDeploymentArray[3].name}.azurewebsites.net'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: '${applicationGatewayName}-beSettings'
        properties: {
          protocol: 'Http'
          port: 80
          cookieBasedAffinity: backendHttpSettingsCollectionCookieBasedAffinity
          pickHostNameFromBackendAddress: backendHttpSettingsCollectionPickHostNameFromBackendAddress
          requestTimeout: backendHttpSettingsCollectionRequestTimeout

        }
      }
    ]
    httpListeners: [
      {
        name: '${applicationGatewayName}-httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, '${applicationGatewayName}-fepubip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, '${applicationGatewayName}-feports')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
      {
        name: '${applicationGatewayName}-httpsListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, '${applicationGatewayName}-fepubip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, '${applicationGatewayName}-https')
          }
          protocol: 'Https'
          sslCertificate:  {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates',applicationGatewayName,wildcardCertName)
          }
          hostNames:[]
          requireServerNameIndication: false
        }
      
      }
    ]
    urlPathMaps: [
        {
        name: '${applicationGatewayName}-Path'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
          }
          pathRules: [
            {
              name: '${appDeploymentArray[0].name}'
              properties: {
                paths: [
                  '/monarch'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[0].name}-wild'
              properties: {
                paths: [
                  '/monarch/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[1].name}'
              properties: {
                paths: [
                  '/portfolios'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[1].name}-wild'
              properties: {
                paths: [
                  '/portfolios/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[2].name}'
              properties: {
                paths: [
                  '/transactions'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[2].name}-wild'
              properties: {
                paths: [
                  '/transactions/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[3].name}'
              properties: {
                paths: [
                  '/accounts/*'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
            {
              name: '${appDeploymentArray[3].name}-wild'
              properties: {
                paths: [
                  '/accounts'
                ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
                }
                backendHttpSettings:  {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
                }
                
              }
            }
          ]

        }
      }
    ]
    requestRoutingRules: [
      {
        name: '${applicationGatewayName}-beRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, '${applicationGatewayName}-httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-bePool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, '${applicationGatewayName}-beSettings')
          }
        }
      }
      {
        name: '${applicationGatewayName}-beRoutingRule-https'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, '${applicationGatewayName}-httpsListener')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', applicationGatewayName, '${applicationGatewayName}-Path')
          }
        }
      }
      
    ]
    privateLinkConfigurations: [
      {
        name: 'pl${applicationGatewayName}'
        properties: {
          ipConfigurations: [
            {
              name: 'plcfg${applicationGatewayName}'
              properties: {
                privateIPAllocationMethod: 'Dynamic'
                primary: false
                subnet: {
                  id: subnetId
                }

              }

            }
          ]
        }
      }
    ]
  }
}

resource appGwPe 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: 'agwpe${applicationGatewayName}'
  location: location
  dependsOn: []
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'agwpe${applicationGatewayName}'
        properties: {
          privateLinkServiceId: applicateGateway.id
          groupIds: [
            '${applicationGatewayName}-fepubip'
          ]
          privateLinkServiceConnectionState: {
            actionsRequired: 'None'
            description: 'Auto Approved'
            status: 'Approved'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    ipConfigurations: []
    customDnsConfigs: []
    customNetworkInterfaceName: 'nicagwpe${applicationGatewayName}'
    subnet: {
      id: subnetId
    }
  }
}

output agwPrincipalId string = agwId.properties.principalId
output applicationGatewayName string = applicateGateway.name
output applicationGatewayId string = applicateGateway.id
