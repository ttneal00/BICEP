param location string
param sqlServerName string
param sqlEpName string
param tags object
param epZoneRedundant bool

@allowed([
  'BC_Gen5_10'
  'BC_Gen5_14'
  'BC_Gen5_18'
  'GP_Fsv2_8'
  'GP_Gen5_10'
  'GP_Fsv2_24'
])
param skuName string 

@allowed([
  'BusinessCritical'
  'GeneralPurpose'
])

param skuTier string

@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string

param minCapacity int
param maxCapacity int

resource sqlEp 'Microsoft.Sql/servers/elasticPools@2022-05-01-preview' = {
  name: '${sqlEpName}/${sqlServerName}'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    perDatabaseSettings: {
      minCapacity: minCapacity
      maxCapacity: maxCapacity
    }
  zoneRedundant: epZoneRedundant
  licenseType: licenseType
  }

}
