param(
    [string]$location,
    [string]$envPrefix,
    [string]$servicebusName
)

$topics = Get-ChildItem ".\parameters\topics\"
$queues = Get-ChildItem ".\parameters\queues\"

if ($location = "eastus") {
    $pshlocation = "East Us"
}
elseif ($location = "westus") {
    $pshlocation = "West Us"
}

if ($envPrefix = "t") {
    $pshenvironmentPrefix = "t"
    $pshenvironmentCode = "tst"
    $pshenvironment = "test"
}
elseif ($envPrefix = "d") {
    $pshenvironmentPrefix = "d"
    $pshenvironmentCode = "dev"
    $pshenvironment = "development"
}
elseif ($envPrefix = "p") {
    $pshenvironmentPrefix = "p"
    $pshenvironmentCode = "prod"
    $pshenvironment = "production"
}

$servicebus = Get-AzServiceBusNamespace|Where-Object{$_.Name -like 'svcbus-mrl-eus*'}
$resourceGroup = get-azresourceGroup|Where-Object{$_.ResourceGroupName -like "rgapp-mrl-eus*" -and $_.Tags.Values -eq $pshenvironment}

$topics| ForEach-Object {
    $topicPath = ".\parameters\topics\" + $_.name
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile ./Infrastructure/Modules/serviceBus/topic.bicep -TemplateParameterFile $topicPath -serviceBusName $servicebus.Name
    Start-Sleep -Seconds 10
}

$queues| ForEach-Object {
    $queuePath = ".\parameters\queues\" + $_.name
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile ./Infrastructure/Modules/serviceBus/queue.bicep -TemplateParameterFile $queuePath -serviceBusName $servicebus.Name
    Start-Sleep -Seconds 10
}