@description('App Service Plan for hosting both API and Web applications')
param appServicePlanName string
param location string = resourceGroup().location
param environment string = 'prod'

var tags = {
  Environment: environment
  Project: 'AlbumViewer'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

@description('Resource ID of the App Service Plan')
output appServicePlanId string = appServicePlan.id

@description('Name of the App Service Plan')
output appServicePlanName string = appServicePlan.name
