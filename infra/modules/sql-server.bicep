@description('Azure SQL Server and Database')
param sqlServerName string
param sqlDatabaseName string
param location string = resourceGroup().location
param environment string = 'prod'
param sqlAdminUsername string
@secure()
param sqlAdminPassword string

// Azure AD Authentication parameters
@description('Enable Azure AD authentication for SQL Server')
param enableAzureADAuth bool = true

@description('Azure AD administrator login name (UPN or group name)')
param azureADAdminLogin string = ''

@description('Azure AD administrator object ID (user or group)')
param azureADAdminObjectId string = ''

@description('Azure AD tenant ID')
param azureADTenantId string = ''

var tags = {
  Environment: environment
  Project: 'AlbumViewer'
  Component: 'Database'
}

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure AD Administrator configuration (conditional deployment)
resource sqlServerAADAdmin 'Microsoft.Sql/servers/administrators@2023-05-01-preview' = if (enableAzureADAuth && !empty(azureADAdminObjectId)) {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: azureADAdminLogin
    sid: azureADAdminObjectId
    tenantId: azureADTenantId
  }
}

resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}


resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    isLedgerOn: false
  }
}

@description('SQL Server fully qualified domain name')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('SQL Server name')
output sqlServerName string = sqlServer.name

@description('SQL Database name')
output sqlDatabaseName string = sqlDatabase.name
