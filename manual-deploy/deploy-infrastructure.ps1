# Deploy Infrastructure to Azure (manual equivalent of GitHub Actions)
# Usage: .\deploy-infrastructure.ps1

param(
    [string]$ResourceGroup = "kiz-albumviewer-rg",
    [string]$Location = "eastus2"
)

# Login to Azure (interactive or with service principal)
# Write-Host "Logging in to Azure..."
# az login

# Deploy Bicep infrastructure
Write-Host "Deploying Bicep infrastructure..."
az deployment sub create `
    --location $Location `
    --template-file "../infra/main.bicep" `
    --parameters "@../infra/parameters.json" `
    --query 'properties.outputs' `
    --output json > outputs.json

# Extract outputs
$outputs = Get-Content outputs.json | ConvertFrom-Json
$apiUrl = $outputs.apiAppUrl.value
$webUrl = $outputs.webAppUrl.value
$sqlServer = $outputs.sqlServerFqdn.value

Write-Host "`nInfrastructure deployed successfully!"
Write-Host "API URL: $apiUrl"
Write-Host "Web URL: $webUrl"
Write-Host "SQL Server: $sqlServer"

# Set API App Connection String for SQL Server Authentication
$apiAppName = $outputs.apiAppName.value
$sqlDb = $outputs.sqlDatabaseName.value
$sqlConnString = "Server=tcp:$sqlServer,1433;Database=$sqlDb;User ID=albumadmin;Password=YourSecurePassword123!;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
Write-Host "Setting Data__SqlServerConnectionString to: $sqlConnString"
az webapp config appsettings set `
    --name $apiAppName `
    --resource-group $ResourceGroup `
    --settings "Data__SqlServerConnectionString=$sqlConnString"

# No need to create managed identity database user for SQL Server authentication
Write-Host "✅ Using SQL Server authentication - no additional database user creation needed!"