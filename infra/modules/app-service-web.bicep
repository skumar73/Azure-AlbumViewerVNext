@description('App Service for the Angular frontend')
param webAppName string
param appServicePlanId string
param location string = resourceGroup().location
param environment string = 'prod'
param applicationInsightsConnectionString string
param logAnalyticsWorkspaceId string
param apiAppUrl string

var tags = {
  Environment: environment
  Project: 'AlbumViewer'
  Component: 'Frontend'
}

resource webAppService 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      appCommandLine: ''
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
      defaultDocuments: [
        'index.html'
      ]
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'API_URL'
          value: apiAppUrl
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: true
    }
    clientAffinityEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

// Enable Application Logs
resource webAppLogsConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webAppService
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Information'
      }
    }
    httpLogs: {
      fileSystem: {
        enabled: true
        retentionInMb: 35
        retentionInDays: 30
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

// Diagnostic settings for Web App Service
resource webAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'web-diagnostics'
  scope: webAppService
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

@description('Default hostname of the web app service')
output webAppUrl string = 'https://${webAppService.properties.defaultHostName}'

@description('Name of the web app service')
output webAppName string = webAppService.name
