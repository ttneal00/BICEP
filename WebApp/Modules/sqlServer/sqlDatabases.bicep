param location string
param sqlDatabaseName string
param sqlServerName string
param elasticPoolId string
param zoneRedundant bool
param tags object

@allowed([
  'BC_Gen5_10'
  'BC_Gen5_14'
  'BC_Gen5_18'
  'GP_Fsv2_8'
  'GP_Gen5_10'
  'GP_Fsv2_24'
  'GP_S_Gen5_1'
  'GP_S_Gen5_6'
  'GP_S_Gen5_14'
])
param skuName string 

@allowed([
  'BusinessCritical'
  'GeneralPurpose'
])

param skuTier string

@allowed([
  'SQL_Latin1_General_CP1_CI_AS'
  'DATABASE_DEFAULT'
])
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@allowed([
  'Geo'
  'GeoZone'
  'Zone'
])
param requestedBackupStorageRedundancy string = 'Geo'

param isLedgerOn bool = false

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview'  = {
  name: '${sqlServerName}/${sqlDatabaseName}'
  location: location
  tags: tags
   sku: {
    name: skuName
    tier: skuTier
   }
   properties: {
    collation: collation
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    isLedgerOn: isLedgerOn
    elasticPoolId: elasticPoolId
    zoneRedundant: zoneRedundant
   }
}



