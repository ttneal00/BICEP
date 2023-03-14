param subnetname string 
param addressprefix string
param nsgid string
//param vnetname string

// var vnetparent = 'Microsoft.Network/virtualNetworks/subnets${vnetname}'

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetname
  properties:{
    addressPrefix: addressprefix
    networkSecurityGroup: {
      id: nsgid
    }
     
  }

}


output subnetid string = subnet.id
