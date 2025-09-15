# AlbumViewer Infrastructure

This folder contains Bicep templates for deploying the AlbumViewer application infrastructure to Azure.

> **Status**: Testing Azure credentials for GitHub Actions deployment

## Architecture

The infrastructure consists of:

- **App Service Plan** (B1 Basic) - Shared hosting plan for both applications
- **API App Service** - Hosts the ASP.NET Core Web API
- **Web App Service** - Hosts the Angular frontend application
- **Azure SQL Server & Database** - Database with Basic DTU pricing
- **Application Insights** - Monitoring and telemetry for both applications
- **Log Analytics Workspace** - Backing store for Application Insights

## Quick Deployment

### Prerequisites

- Azure CLI installed and logged in
- Appropriate permissions to create resources in the target subscription

### Deploy Infrastructure

```bash
# Deploy to Azure using parameters file
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters @parameters.json
```

### Manual Deployment with Custom Parameters

```bash
# Deploy with custom parameters
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters resourceGroupName="your-rg-name" \
              location="eastus2" \
              sqlAdminPassword="YourSecurePassword123!"
```

## Parameters

The `parameters.json` file contains all configurable values:

| Parameter                 | Description                  | Default Value              |
| ------------------------- | ---------------------------- | -------------------------- |
| `resourceGroupName`       | Name of the resource group   | `kiz-albumviewer-rg`       |
| `location`                | Azure region for deployment  | `eastus2`                  |
| `appServicePlanName`      | Name of the App Service Plan | `kiz-albumviewer-plan`     |
| `apiAppName`              | Name of the API App Service  | `kiz-albumviewer-api`      |
| `webAppName`              | Name of the Web App Service  | `kiz-albumviewer-web`      |
| `sqlServerName`           | Name of the SQL Server       | `kiz-albumviewer-sql`      |
| `sqlDatabaseName`         | Name of the SQL Database     | `kiz-albumviewer-db`       |
| `applicationInsightsName` | Name of App Insights         | `kiz-albumviewer-insights` |
| `sqlAdminUsername`        | SQL Server admin username    | `albumadmin`               |
| `sqlAdminPassword`        | SQL Server admin password    | `AlbumDemo123!`            |

## Outputs

After deployment, the template provides these outputs:

- `apiAppUrl` - URL of the deployed API
- `webAppUrl` - URL of the deployed frontend
- `sqlServerFqdn` - SQL Server fully qualified domain name
- `applicationInsightsInstrumentationKey` - App Insights key

## Security Notes

**Important**: This is a demo configuration with simplified security:

- SQL Server allows Azure services access
- Connection strings are stored in App Service app settings
- Default SQL admin credentials are used

For production deployments, consider:

- Using Azure Key Vault for secrets
- Implementing network restrictions
- Using managed identities where possible
- Enabling private endpoints

## Resource Cleanup

To delete all resources:

```bash
# Delete the entire resource group
az group delete --name kiz-albumviewer-rg --yes --no-wait
```

## Troubleshooting

### Common Issues

1. **SQL Server name conflicts**: SQL Server names must be globally unique
2. **App Service name conflicts**: App Service names must be globally unique
3. **Location availability**: Ensure all services are available in the selected region

### Viewing Deployment Status

```bash
# Check deployment status
az deployment sub show --name main --query properties.provisioningState

# View deployment outputs
az deployment sub show --name main --query properties.outputs
```
