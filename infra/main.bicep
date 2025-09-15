@description('Main template for AlbumViewer application infrastructure')
// Parameters
param resourceGroupName string = 'kiz-albumviewer-rg'
param location string = 'eastus2'
param environment string = 'prod'
param appServicePlanName string = 'kiz-albumviewer-plan'
param apiAppName string = 'kiz-albumviewer-api'
param webAppName string = 'kiz-albumviewer-web'
param sqlServerName string = 'kiz-albumviewer-sql'
param sqlDatabaseName string = 'kiz-albumviewer-db'
param applicationInsightsName string = 'kiz-albumviewer-insights'
param logAnalyticsWorkspaceName string = 'kiz-albumviewer-logs'
param sqlAdminUsername string = 'albumadmin'
@secure()
param sqlAdminPassword string

targetScope = 'subscription'

// Create Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: {
    Environment: environment
    Project: 'AlbumViewer'
  }
}

// Deploy Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    location: location
    environment: environment
  }
}

// Deploy Application Insights
module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  scope: rg
  params: {
    applicationInsightsName: applicationInsightsName
    location: location
    environment: environment
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

// Deploy App Service Plan
module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  scope: rg
  params: {
    appServicePlanName: appServicePlanName
    location: location
    environment: environment
  }
}

// Deploy SQL Server and Database
module sqlServer 'modules/sql-server.bicep' = {
  name: 'sqlServer'
  scope: rg
  params: {
    sqlServerName: sqlServerName
    sqlDatabaseName: sqlDatabaseName
    location: location
    environment: environment
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
  }
}

// Deploy API App Service (ASP.NET Core API) - Create this FIRST
module apiAppService 'modules/app-service-api.bicep' = {
  name: 'apiAppService'
  scope: rg
  params: {
    apiAppName: apiAppName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    location: location
    environment: environment
    applicationInsightsConnectionString: appInsights.outputs.applicationInsightsConnectionString
    sqlConnectionString: 'Server=tcp:${sqlServer.outputs.sqlServerFqdn},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    webAppUrl: 'https://${webAppName}.azurewebsites.net' // Forward reference is OK here
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

// Deploy Web App Service (Angular frontend) - Create this AFTER API
module webAppService 'modules/app-service-web.bicep' = {
  name: 'webAppService'
  scope: rg
  params: {
    webAppName: webAppName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    location: location
    environment: environment
    applicationInsightsConnectionString: appInsights.outputs.applicationInsightsConnectionString
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    apiAppUrl: apiAppService.outputs.apiAppUrl // Now we can reference the actual API URL
  }
}

// Outputs
@description('Resource Group Name')
output resourceGroupName string = rg.name

@description('API App Service URL')
output apiAppUrl string = apiAppService.outputs.apiAppUrl

@description('Web App Service URL')
output webAppUrl string = webAppService.outputs.webAppUrl

@description('SQL Server FQDN')
output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn

@description('Application Insights Instrumentation Key')
output applicationInsightsInstrumentationKey string = appInsights.outputs.applicationInsightsInstrumentationKey

@description('Application Insights Connection String')
output applicationInsightsConnectionString string = appInsights.outputs.applicationInsightsConnectionString

@description('Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId
