@description('Application Insights for monitoring both API and Web applications')
param applicationInsightsName string
param location string = resourceGroup().location
param environment string = 'prod'
param logAnalyticsWorkspaceId string

var tags = {
  Environment: environment
  Project: 'AlbumViewer'
  Component: 'Monitoring'
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('Application Insights Instrumentation Key')
output applicationInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('Application Insights Connection String')
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString

@description('Application Insights name')
output applicationInsightsName string = applicationInsights.name
