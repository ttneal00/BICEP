param webAppName string
param properties object

resource parentWebApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

resource appsettings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: parentWebApp
  name: 'appsettings'
  properties: properties
}
