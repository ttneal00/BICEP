param location string
param appServicePlanName string
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
])
param skuSize string 
param perSiteScaling bool = false
param elasticScaleEnabled bool = false
param targetWorkerCount int = 0
param targetWorkerSizeId int = 0
param zoneRedundant bool = false


resource appSvcPln 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    size: skuSize
    name: skuSize
  }
  kind: 'Linux'
  properties: {
    perSiteScaling: perSiteScaling
    elasticScaleEnabled: elasticScaleEnabled
    targetWorkerCount: targetWorkerCount
    targetWorkerSizeId: targetWorkerSizeId
    zoneRedundant: zoneRedundant
  }
}


output id string = appSvcPln.id
