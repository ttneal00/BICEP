param tableName string
param storageAccountName string

resource storageTable 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  name: '${storageAccountName}/${tableName}'
}
