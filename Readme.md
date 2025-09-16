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

1. **Configure Secrets**: In your GitHub repo, set the `AZURE_CREDENTIALS` secret (Service Principal JSON).
2. **Push Changes**: Any push to the repo triggers the workflows:
   - `deploy-infrastructure.yml`: Deploys/updates Azure resources via Bicep.
   - `deploy-api.yml`: Builds, tests, publishes, and deploys the .NET API.
   - `deploy-web.yml`: Builds and deploys the Angular frontend.
3. **Monitor Actions**: View progress and logs in the GitHub Actions tab.

### 2. Deploy Manually with PowerShell Scripts

1. **Install Prerequisites**:
   - Azure CLI (`az`)
   - .NET 8 SDK
   - Node.js (for Angular build)
2. **Login to Azure**:
   ```powershell
   az login
   ```
3. **Deploy Infrastructure**:
   ```powershell
   cd manual-deploy
   ./deploy-infrastructure.ps1
   ```
4. **Deploy API**:
   ```powershell
   ./deploy-api.ps1
   ```
5. **Deploy Web App**:
   ```powershell
   ./deploy-web.ps1
   ```

All scripts mirror the GitHub Actions exactly, so results are consistent between local and CI/CD deployments.

## Notes

- **local_settings.txt** is for local testing only and is not tracked in the repo.
- For more details, see the markdown docs in the `docs/` folder.
- For original project details, see [West Wind Album Viewer](https://albumviewer.west-wind.com).

---

**This version is designed for secure, repeatable, and cloud-native deployments on Azure.**
