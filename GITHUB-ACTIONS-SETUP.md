# GitHub Actions Setup for AlbumViewer

This document explains how to configure GitHub Actions for automated deployment of the AlbumViewer application to Azure.

## Required GitHub Secrets

You need to configure the following secret in your GitHub repository:

### AZURE_CREDENTIALS

This secret contains the Azure service principal credentials for GitHub Actions to authenticate with Azure.

#### Creating the Azure Service Principal

1. **Create a service principal** with contributor access to your subscription:

   ```bash
   az ad sp create-for-rbac --name "AlbumViewer-GitHub-Actions" \
     --role contributor \
     --scopes /subscriptions/{subscription-id} \
     --sdk-auth
   ```

2. **Copy the entire JSON output** and add it as a GitHub secret named `AZURE_CREDENTIALS`.

   The JSON should look like this:

   ```json
   {
     "clientId": "xxxx-xxxx-xxxx-xxxx",
     "clientSecret": "xxxx-xxxx-xxxx-xxxx",
     "subscriptionId": "xxxx-xxxx-xxxx-xxxx",
     "tenantId": "xxxx-xxxx-xxxx-xxxx"
   }
   ```

#### Adding Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AZURE_CREDENTIALS`
5. Value: Paste the entire JSON from step 1
6. Click **Add secret**

## Workflow Overview

The deployment is split into three independent GitHub Actions workflows:

### 1. Infrastructure Deployment (`deploy-infrastructure.yml`)

**Triggers on:**

- Changes to `infra/**` folder
- Manual dispatch

**Actions:**

- Deploys Bicep templates to create all Azure resources
- Outputs the URLs of the created App Services

### 2. API Deployment (`deploy-api.yml`)

**Triggers on:**

- Changes to `src/AlbumViewerNetCore/**` folder
- Manual dispatch

**Actions:**

- Sets up .NET 8
- Builds and tests the ASP.NET Core API
- Deploys to Azure App Service

### 3. Web App Deployment (`deploy-web.yml`)

**Triggers on:**

- Changes to `src/AlbumViewerAngular/**` folder
- Manual dispatch

**Actions:**

- Sets up Node.js 18
- Updates API URL in Angular environment file
- Builds Angular application
- Deploys to Azure App Service

## Deployment Strategy

### Path-based Triggers

Each workflow only runs when relevant files change:

- **Infrastructure changes** → Deploy infrastructure only
- **API code changes** → Deploy API only
- **Angular code changes** → Deploy Web app only

### Manual Deployments

All workflows can be triggered manually via the "Run workflow" button in GitHub Actions.

## Triggering Deployments

### Automatic Deployments

The workflows trigger automatically based on changed files:

- **Infrastructure**: Push changes to `infra/**` folder
- **API**: Push changes to `src/AlbumViewerNetCore/**` folder
- **Web App**: Push changes to `src/AlbumViewerAngular/**` folder

### Manual Deployments

- Go to **Actions** tab in GitHub
- Select the specific workflow you want to run
- Click **Run workflow** button
- Choose the branch and click **Run workflow**

### Typical Deployment Order

1. **First time**: Run infrastructure deployment
2. **API changes**: Run API deployment
3. **Frontend changes**: Run Web app deployment

## Monitoring Deployments

1. Go to your GitHub repository
2. Click the **Actions** tab
3. You'll see three workflows:
   - **Deploy Infrastructure to Azure**
   - **Deploy API to Azure**
   - **Deploy Web App to Azure**
4. Select any workflow to view logs and deployment status

### Workflow Dependencies

- **API and Web deployments** are independent of each other
- **Infrastructure** should be deployed first (contains the App Services)
- **API URL** is automatically configured in the Web app during its deployment

## Troubleshooting

### Common Issues

1. **Authentication Failure**

   - Verify `AZURE_CREDENTIALS` secret is correctly formatted
   - Ensure the service principal has contributor access

2. **Resource Name Conflicts**

   - SQL Server names must be globally unique
   - App Service names must be globally unique
   - Update `infra/parameters.json` if needed

3. **Build Failures**
   - Check that all dependencies are properly configured
   - Verify .NET and Node.js versions match requirements

### Viewing Logs

- **Azure App Service logs**: Use Azure portal → App Service → Log stream
- **GitHub Actions logs**: Available in the Actions tab of your repository
- **Application Insights**: Monitor application performance and errors

## Next Steps

After successful deployment:

1. **Test your application** at the provided URLs
2. **Configure custom domains** if needed
3. **Set up monitoring alerts** in Application Insights
4. **Review security settings** for production use

## Security Considerations

This is a demo configuration. For production deployments, consider:

- Using Azure Key Vault for secrets
- Implementing network restrictions
- Using managed identities where possible
- Setting up proper backup and disaster recovery
