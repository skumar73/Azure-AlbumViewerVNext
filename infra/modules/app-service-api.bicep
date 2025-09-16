@description('App Service for the ASP.NET Core API')
param apiAppName string
param appServicePlanId string
param location string = resourceGroup().location
param environment string = 'prod'
param applicationInsightsConnectionString string
param sqlConnectionString string
param webAppUrl string
param logAnalyticsWorkspaceId string

var tags = {
  Environment: environment
  Project: 'AlbumViewer'
  Component: 'API'
}

resource apiAppService 'Microsoft.Web/sites@2023-01-01' = {
  name: apiAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      netFrameworkVersion: 'v8.0'
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      use32BitWorkerProcess: false
      webSocketsEnabled: false
      alwaysOn: true
      managedPipelineMode: 'Integrated'
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: true
        }
      ]
      cors: {
        allowedOrigins: [
          webAppUrl
        ]
        supportCredentials: false
      }
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Production'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'Data__SqlServerConnectionString'
          value: sqlConnectionString
        }
        {
          name: 'Data__useSqLite'
          value: 'false'
        }
      ]
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: true
      requestTracingEnabled: true
      requestTracingExpirationTime: '9999-12-31T23:59:00Z'
      connectionStrings: [
        {
          name: 'DefaultConnection'
          connectionString: sqlConnectionString
          type: 'SQLAzure'
        }
      ]
    }
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

// Diagnostic settings for API App Service
resource apiAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'api-diagnostics'
  scope: apiAppService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

@description('Default hostname of the API app service')
output apiAppUrl string = 'https://${apiAppService.properties.defaultHostName}'

@description('Name of the API app service')
output apiAppName string = apiAppService.name
