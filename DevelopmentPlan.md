# Development Plan: Azure Deployment for AlbumViewer Application

## Overview

This document outlines the phases for deploying the AlbumViewer application (C# ASP.NET Core API + Angular frontend) to Azure using Bicep templates and GitHub Actions.

**Key Principles**: Keep it simple, avoid over-engineering, focus on getting a working deployment pipeline.

## Project Structure

```
/infra/
├── main.bicep                 # Main deployment template
├── parameters.json            # Configuration parameters
├── modules/
│   ├── app-service-plan.bicep # Shared app service plan
│   ├── app-service-api.bicep  # C# API app service
│   ├── app-service-web.bicep  # Angular frontend app service
│   ├── sql-server.bicep       # Azure SQL Server & Database
│   ├── log-analytics.bicep    # Log Analytics Workspace
│   └── app-insights.bicep     # Application Insights
└── README.md                  # Deployment instructions

/.github/workflows/
└── deploy-azure.yml           # GitHub Actions workflow
```

## Phase 1: Infrastructure Setup (Day 1)

**Goal**: Create Bicep templates for all Azure resources

### Tasks:

1. **Create infra folder structure**

   - Create `/infra/` directory
   - Create `/infra/modules/` subdirectory

2. **Create parameters file** (`infra/parameters.json`)

   - Resource group: `kiz-albumviewer-rg`
   - Region: `eastus2` (default)
   - Environment: `prod`
   - App names: `kiz-albumviewer-api`, `kiz-albumviewer-web`
   - SQL server name: `kiz-albumviewer-sql`
   - Database name: `kiz-albumviewer-db`

3. **Create Bicep modules**:

   - **App Service Plan** (B1 Basic tier - shared between both apps)
   - **App Service for API** (C# ASP.NET Core)
   - **App Service for Frontend** (Angular static files)
   - **Azure SQL Server + Database** (Basic DTU)
   - **Application Insights** (linked to both app services)

4. **Create main Bicep template** (`infra/main.bicep`)
   - Orchestrates all modules
   - Outputs connection strings and URLs

**Deliverable**: Complete Bicep infrastructure templates that can deploy all resources

## Phase 2: GitHub Actions Workflow (Day 2)

**Goal**: Automate deployment of infrastructure and applications

### Tasks:

1. **Create GitHub Actions workflow** (`.github/workflows/deploy-azure.yml`)

   - Triggers: Push to any branch + manual dispatch
   - Uses Azure/login action
   - Deploys Bicep templates
   - Builds and deploys C# API
   - Builds and deploys Angular app

2. **Configure GitHub Secrets**:

   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`

3. **Workflow Steps**:
   - Checkout code
   - Login to Azure
   - Deploy infrastructure (Bicep)
   - Build C# API (`dotnet publish`)
   - Deploy API to App Service
   - Build Angular app (`ng build --prod`)
   - Deploy Angular to App Service

**Deliverable**: Working GitHub Actions workflow that deploys everything automatically

## Phase 3: Application Configuration (Day 3)

**Goal**: Configure applications to work with Azure resources

### Tasks:

1. **API Configuration**:

   - Update connection string app setting in API App Service
   - Configure Application Insights instrumentation key
   - Set CORS policy for Angular frontend URL
   - Configure any other required app settings

2. **Angular Configuration**:

   - Update API base URL to point to Azure API App Service
   - Configure production build settings
   - Ensure routing works correctly in App Service

3. **Database Setup**:
   - Verify Entity Framework code-first creates schema on startup
   - Test connection from API to Azure SQL Database
   - Verify sample data loads correctly

**Deliverable**: Fully configured and working application on Azure

## Phase 4: Testing & Documentation (Day 4)

**Goal**: Verify everything works and document the process

### Tasks:

1. **End-to-End Testing**:

   - Test infrastructure deployment from scratch
   - Test application deployment via GitHub Actions
   - Test all application functionality in Azure
   - Test parameter file updates trigger redeployment

2. **Documentation**:

   - Update `/infra/README.md` with deployment instructions
   - Document parameter file structure
   - Document manual deployment steps (if needed)
   - Document troubleshooting common issues

3. **Cleanup & Optimization**:
   - Review resource sizing (ensure Basic/B1 tiers are appropriate)
   - Verify Application Insights is properly configured
   - Test monitoring and logging capabilities

**Deliverable**: Production-ready deployment pipeline with documentation

## Success Criteria

- [ ] Infrastructure deploys cleanly via Bicep
- [ ] GitHub Actions workflow deploys both infrastructure and applications
- [ ] C# API connects to Azure SQL Database and creates schema
- [ ] Angular frontend communicates with API
- [ ] Application Insights collects telemetry from both services
- [ ] Parameter file changes trigger automatic redeployment
- [ ] Complete documentation for future deployments

## Technical Decisions Made

1. **Two App Services** instead of single container - easier to manage and scale independently
2. **Basic DTU database** - simple pricing model, sufficient for demo
3. **No Key Vault** - connection strings in app settings (demo scenario)
4. **B1 Basic App Service Plan** - cost-effective shared plan
5. **Single environment** - no dev/staging complexity
6. **GitHub Actions over Azure DevOps** - simpler setup for GitHub repositories

## Risk Mitigation

- Keep Bicep templates modular for easier troubleshooting
- Use well-documented Azure resource configurations
- Include resource cleanup instructions
- Test deployment multiple times during development
- Document all manual steps that can't be automated
