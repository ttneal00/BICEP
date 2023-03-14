//Some Helpful Commands at the bottom
@description(' Name of the vnet the vmnic will be hosted')
param vNetName string 
@description(' Name of the subnet the vmnic will be hosted')
param subnetName string
@description(' Name of the resourcegroup hosting the vnet')
param vnetrgname string

param vmName string

param location string 

//virtual Machine Variables

@description('To obtain vmsize run the following command: Get-AzVMSize -Location <replace with desired location>')
@allowed([
  'Standard_A3'
  'Standard_F4'
  'Standard_B2ms'
])
param vmSize string
@allowed([
  'MicrosoftWindowsServer'
  'Canonical'
])
param imagePublisher string

@allowed([
  'WindowsServer'
  'UbuntuServer'
])
param imageOffer string

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
'2008-R2-SP1'
'2008-R2-SP1-smalldisk'
'2012-Datacenter'
'2012-datacenter-gensecond'
'2012-Datacenter-smalldisk'
'2012-datacenter-smalldisk-g2'
'2012-Datacenter-zhcn'
'2012-datacenter-zhcn-g2'
'2012-R2-Datacenter'
'2012-r2-datacenter-gensecond'
'2012-R2-Datacenter-smalldisk'
'2012-r2-datacenter-smalldisk-g2'
'2012-R2-Datacenter-zhcn'
'2012-r2-datacenter-zhcn-g2'
'2016-Datacenter'
'2016-datacenter-gensecond'
'2016-datacenter-gs'
'2016-Datacenter-Server-Core'
'2016-datacenter-server-core-g2'
'2016-Datacenter-Server-Core-smalldisk'
'2016-datacenter-server-core-smalldisk-g2'
'2016-Datacenter-smalldisk'
'2016-datacenter-smalldisk-g2'
'2016-Datacenter-with-Containers'
'2016-datacenter-with-containers-g2'
'2016-datacenter-with-containers-gs'
'2016-Datacenter-zhcn'
'2016-datacenter-zhcn-g2'
'2019-Datacenter'
'2019-Datacenter-Core'
'2019-datacenter-core-g2'
'2019-Datacenter-Core-smalldisk'
'2019-datacenter-core-smalldisk-g2'
'2019-Datacenter-Core-with-Containers'
'2019-datacenter-core-with-containers-g2'
'2019-Datacenter-Core-with-Containers-smalldisk'
'2019-datacenter-core-with-containers-smalldisk-g2'
'2019-datacenter-gensecond'
'2019-datacenter-gs'
'2019-Datacenter-smalldisk'
'2019-datacenter-smalldisk-g2'
'2019-Datacenter-with-Containers'
'2019-datacenter-with-containers-g2'
'2019-datacenter-with-containers-gs'
'2019-Datacenter-with-Containers-smalldisk'
'2019-datacenter-with-containers-smalldisk-g2'
'2019-Datacenter-zhcn'
'2019-datacenter-zhcn-g2'
'2022-datacenter'
'2022-datacenter-azure-edition'
'2022-datacenter-azure-edition-core'
'2022-datacenter-azure-edition-core-smalldisk'
'2022-datacenter-azure-edition-smalldisk'
'2022-datacenter-core'
'2022-datacenter-core-g2'
'2022-datacenter-core-smalldisk'
'2022-datacenter-core-smalldisk-g2'
'2022-datacenter-g2'
'2022-datacenter-smalldisk'
'2022-datacenter-smalldisk-g2'
])
param imageOSsku string
param imageVersion string

@secure()
param adminPassword string 
param adminUsername string = '${vmName}-Admin'

// Storage Account Variables

@allowed([
  'Standard_LRS'
  'Premium_ZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Premium_LRS' 
  'Standard_ZRS'
])
param storageskuname string

@maxLength(8)
param storageAccountPrefix string



@allowed([
  'StorageV2'
  'FileStorage'
  'BlockBlobStorage'
])
param sakind string
var saname = '${toLower(storageAccountPrefix)}${uniqueString(resourceGroup().id)}'

///////////////////////////
// RESOURCES AND MODULES//
/////////////////////////

resource vmStorage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: saname
  location: location
  sku: {
    name: storageskuname
  }
  kind: sakind
}

resource vmnic 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: '${vmName}-NIC'
  location: location
  dependsOn: [
  ]
  properties:{
    ipConfigurations:[
      {
        name: '${vmName}-IPconfig'
        properties: {
          subnet:{
            id: resourceId(vnetrgname,'Microsoft.Network/virtualNetworks/subnets',vNetName, subnetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  dependsOn:[
    
  ]
  properties:{
     hardwareProfile:{
      vmSize: vmSize
    }

    osProfile:{
      adminPassword: adminPassword
      adminUsername: adminUsername
      computerName: vmName
    }
    storageProfile:{
      imageReference:{
        publisher: imagePublisher
        offer: imageOffer
        sku: imageOSsku
        version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
      {
        diskSizeGB: 1023
        lun: 0
        createOption: 'Empty'
      }
    ]
    }
  networkProfile:{

    networkInterfaces:[
      {
        id: resourceId('Microsoft.Network/networkInterfaces',vmnic.name)
      }
    ]
     
  }
  diagnosticsProfile:{
    bootDiagnostics:{
      enabled: true
      storageUri: vmStorage.properties.primaryEndpoints.blob
    }
  }
  } 

} 

output ipaddress string = vmnic.properties.ipConfigurations[0].properties.privateIPAddress
output adminUserName string = adminUsername



