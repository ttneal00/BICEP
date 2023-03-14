param subnetname string 
param addressprefix string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' =  {
  name: subnetname
  properties:{
    addressPrefix: addressprefix
  }
}


output subnetid string = subnet.id
output addressPrefix string = subnet.properties.addressPrefix
