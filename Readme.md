# Azure AlbumViewerVNext

This is a modernized fork of the original West Wind Album Viewer ASP.NET Core Sample, updated for Azure-native deployment, security, and maintainability. It features a .NET 8 API backend, Angular frontend, and full Infrastructure-as-Code (Bicep) for Azure. This version is production-ready for cloud and CI/CD workflows.

## Major Changes from the Original Fork

- **Azure-First Infrastructure**: All resources (App Service, SQL, Managed Identity, App Insights, etc.) are provisioned via Bicep templates in the `infra/` folder.
- **Managed Identity for SQL**: The API uses Azure Managed Identity for secure, passwordless SQL Server access. No SQL credentials in code or config.
- **Removed SQLite Support**: The backend now exclusively uses Azure SQL. All SQLite code, config, and dependencies have been removed for simplicity and security.
- **CI/CD with GitHub Actions**: Automated workflows for infrastructure, API, and web deployments. See `.github/workflows/`.
- **Manual Deployment Scripts**: PowerShell scripts in `manual-deploy/` mirror the GitHub Actions, allowing local testing and deployment without repo changes.
- **Documentation Organized**: All markdown docs are in the `docs/` folder, except this root Readme for GitHub visibility.
- **Modernized .NET and Angular**: Upgraded to .NET 8 and latest Angular CLI. All dependencies updated.
- **Security Best Practices**: No secrets in code. Local testing secrets are in `local_settings.txt` (not in repo).

## Project Structure

- `infra/` — Bicep templates for Azure resources
- `src/AlbumViewerNetCore/` — .NET 8 API backend
- `src/AlbumViewerAngular/` — Angular frontend
- `manual-deploy/` — PowerShell scripts for manual deployment
- `.github/workflows/` — GitHub Actions for CI/CD
- `docs/` — Additional documentation

## How to Deploy to Azure

You can deploy using either GitHub Actions (CI/CD) or the provided PowerShell scripts. Both methods are functionally equivalent.

### 1. Deploy Using GitHub Actions (Recommended for CI/CD)

1. **Configure Secrets**: In your GitHub repo, set the required secrets (see GitHub Secrets section below).
2. **Push Changes**: Any push to the repo triggers the workflows:
   - `deploy-infrastructure.yml`: Deploys/updates Azure resources via Bicep.
   - `deploy-api.yml`: Builds, tests, publishes, and deploys the .NET API.
   - `deploy-web.yml`: Builds and deploys the Angular frontend.
3. **Monitor Actions**: View progress and logs in the GitHub Actions tab.

## GitHub Secrets Configuration

For GitHub Actions to deploy to Azure, you need to configure the following secrets in your repository settings:

### Required Secrets

1. **`AZURE_CLIENT_ID`** - Azure Service Principal Client ID
2. **`AZURE_CLIENT_SECRET`** - Azure Service Principal Client Secret
3. **`AZURE_CREDENTIALS`** - Complete Service Principal credentials JSON (legacy format)
4. **`AZURE_SUBSCRIPTION_ID`** - Your Azure Subscription ID
5. **`AZURE_TENANT_ID`** - Your Azure Tenant ID

### Setting Up Azure Service Principal

To get the values for these secrets, create an Azure Service Principal:

```bash
# Login to Azure
az login

# Create service principal (replace with your subscription ID and resource group)
az ad sp create-for-rbac --name "albumviewer-github-actions" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/kiz-albumviewer-rg \
  --sdk-auth
```

This command will output JSON credentials. Use the values to populate your GitHub secrets:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", // → AZURE_CLIENT_ID
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", // → AZURE_CLIENT_SECRET
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", // → 
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", // → AZURE_TENANT_ID
}
```

**Copy the entire JSON output as the value for `AZURE_CREDENTIALS`** (this is used by some workflow steps that require the legacy format).

### How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the name and value as specified above

### 2. Deploy Manually with PowerShell Scripts

1. **Install Prerequisites**:
   - Azure CLI (`az`)
   - .NET 8 SDK
   - Node.js (for Angular build)
2. **Login to Azure**:
   ```powershell
   az login
   ```
3. **Configure Parameters**: Update `infra/parameters.json` with your specific values:
   ```json
   {
     "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
     "contentVersion": "1.0.0.0",
     "parameters": {
       "sqlAdminPassword": {
         "value": "YourSecurePassword123!"
       }
     }
   }
   ```
4. **Deploy Infrastructure**:
   ```powershell
   cd manual-deploy
   ./deploy-infrastructure.ps1
   ```
5. **Deploy API**:
   ```powershell
   ./deploy-api.ps1
   ```
6. **Deploy Web App**:
   ```powershell
   ./deploy-web.ps1
   ```

All scripts mirror the GitHub Actions exactly, so results are consistent between local and CI/CD deployments.

## Troubleshooting

### Common Issues

**GitHub Actions Authentication Failures**

- Verify `AZURE_CREDENTIALS` secret is properly formatted JSON
- Ensure the service principal has `Contributor` role on the resource group
- Check that the subscription ID in the credentials matches your target subscription

**SQL Connection Issues**

- Verify `SQL_ADMIN_PASSWORD` meets Azure SQL complexity requirements
- Check that the SQL firewall allows Azure services (configured automatically)
- Ensure the connection string format matches the authentication method being used

**Deployment Failures**

- Check Azure quotas and regional availability for the resources being deployed
- Verify the resource group exists or can be created in the target subscription
- Review Azure Activity Logs for detailed error messages

### Viewing Deployment Logs

**GitHub Actions**: Check the Actions tab in your repository for detailed logs of each deployment step.

**Manual Deployment**:

```powershell
# View recent deployments
az deployment group list --resource-group kiz-albumviewer-rg --output table

# Get deployment details
az deployment group show --resource-group kiz-albumviewer-rg --name DEPLOYMENT_NAME
```

## Notes

- **local_settings.txt** is for local testing only and is not tracked in the repo.
- For more details, see the markdown docs in the `docs/` folder.
- For original project details, see [West Wind Album Viewer](https://albumviewer.west-wind.com).

---

**This version is designed for secure, repeatable, and cloud-native deployments on Azure.**
