param applicationInsightsName string
param location string
param globalTags object
//param logAnalyticsWorkspaceId string

@allowed([
  'web'
  'ios'
  'other'
  'store'
  'java'
  'phone'
])
param kind string = 'web'



resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: globalTags
  kind: kind
  properties: {
    Application_Type: 'web'
  }
}


output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output connectionString string = applicationInsights.properties.ConnectionString
