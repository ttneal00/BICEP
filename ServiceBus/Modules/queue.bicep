///////////////////////////////
// Parameters and Variables
///////////////////////////////

param serviceBusName string
// param location string
// param environmentPrefix string
// param connectionsServicebusName string = 'servicebus'
// param sharedSubscriptionId string
// param sharedAppResourceGroupName string
// param logicAppSasId string
// param logicAppSasName string
// param logicAppSasApiVersion string
param queues array
param queueDefaultProperties object


//////////////////////////
// Resource  Deployments
//////////////////////////


resource serviceBusParent 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusName
}

resource queueLoop 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' =[for (queue, i) in queues:  {
  name: queue.name
 parent: serviceBusParent
 properties: queueDefaultProperties.properties
}]



