param containerName string

param storageAccountName string

resource storageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccountName}/${containerName}'
}
