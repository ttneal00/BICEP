@description('Name of the Service Bus namespace')
param serviceBusName string
param topicConfigs object
param subscriptions array
param subscriptionConfigDefaults object
param topicName string
//param environmentPrefix string

@description('References an existing Servicebus Namespace')
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' existing = {
  name: serviceBusName
}

//////////////////////////////////////////////
/// TOPIC DEPLOYMENT
//////////////////////////////////////////////

@description('Deploys a single topic into an existing servicebus.')
resource Topic 'Microsoft.ServiceBus/namespaces/topics@2021-06-01-preview' = {
  parent: serviceBusNamespace
  name: topicName
  properties: topicConfigs.properties
  dependsOn: []
}

/////////////////////////////////////////////////
// SUBSCRIPTION AND RULES DEPLOYMENT
/////////////////////////////////////////////////

resource serviceBusSubscriptionTopic1 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2021-06-01-preview' =[for (subscription, i) in subscriptions:  {
  parent: Topic
  name: '${subscriptions[i].name}'
  properties: subscriptionConfigDefaults.properties
}]

resource subscriptionRule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-06-01-preview' = [for (subscription, i) in subscriptions:{
  parent: serviceBusSubscriptionTopic1[i]
  name: '${serviceBusSubscriptionTopic1[i].name}-rule'
  properties: subscriptionConfigDefaults.rules
}]
