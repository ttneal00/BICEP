//////////////////////////
// Parameters
/////////////////////////

param bastionHostName string = 'Bastionhost'
param ipConfname string = 'bastionIpConf'
param location string 
param subnetid string
param domainNameLabel string 
param publicIPAddressName string

//////////////////////////////////////////////////////////
//////  Resources
/////////////////////////////////////////////////////////

resource StandardStaticPip 'Microsoft.Network/publicIPAddresses@2021-02-01' =  {
  name: '${publicIPAddressName}-Std'
  location: location
    sku:{
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: domainNameLabel
    }
  }

}

resource bastionHostres 'Microsoft.Network/bastionHosts@2020-07-01' = {
  name: bastionHostName
  location: location
  properties:{
    ipConfigurations:[
      {
        name: ipConfname
        properties: {
          subnet: {
            id: subnetid
          }
          publicIPAddress: {
            id: StandardStaticPip.id
          }
        }
      }
    ]
  }
}


output IPaddress string = StandardStaticPip.properties.ipAddress

