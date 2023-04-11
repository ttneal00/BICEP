param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'rwdlacup'
  signedServices: 'b'
  signedExpiry: '2026-04-25T00:00:00Z'
  signedProtocol: 'https'
  keyToSign: 'key2'
}

output sasToken string = storageAccount.listAccountSas(storageAccount.apiVersion, sasConfig).accountSasToken
