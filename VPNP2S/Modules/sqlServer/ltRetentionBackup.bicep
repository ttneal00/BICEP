// Params and Vars

param sqlRtName string
param sqlServerName string
param monthlyRetention string = 'P1Y'
param weeklyRetention string = 'P1M'
param weekOfYear int = 10
param yearlyRetention string = 'P5Y'

// Resource Deployment

resource symbolicname 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2022-05-01-preview' = {
  name: '${sqlServerName}/${sqlRtName}'
  properties: {
    monthlyRetention: monthlyRetention
    weeklyRetention: weeklyRetention
    weekOfYear: weekOfYear
    yearlyRetention: yearlyRetention
  }
}
