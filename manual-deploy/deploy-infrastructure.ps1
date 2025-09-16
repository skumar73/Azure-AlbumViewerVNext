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

# Set API App Connection String for Managed Identity
$apiAppName = $outputs.apiAppName.value
$sqlDb = $outputs.sqlDatabaseName.value
$miConnString = "Server=tcp:$sqlServer,1433;Database=$sqlDb;Authentication=Active Directory Managed Identity;"
Write-Host "Setting Data__SqlServerConnectionString to: $miConnString"
az webapp config appsettings set `
    --name $apiAppName `
    --resource-group $ResourceGroup `
    --settings "Data__SqlServerConnectionString=$miConnString"

# Create database user for managed identity
Write-Host "Creating database user for managed identity..."
$managedIdentityName = "kiz-albumviewer-udmi"
$sqlQuery = @"
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$managedIdentityName')
BEGIN
    CREATE USER [$managedIdentityName] FROM EXTERNAL PROVIDER;
END
ALTER ROLE db_owner ADD MEMBER [$managedIdentityName];
"@

# Connect to SQL using your Azure AD credentials and execute the query
Write-Host "Executing SQL command to grant database access to managed identity..."
try {
    az sql query --server $sqlServer --database $sqlDb --auth-type ActiveDirectoryIntegrated --execute-command $sqlQuery
    Write-Host "✅ Database user created and permissions granted successfully!"
}
catch {
    Write-Host "⚠️ Failed to create database user. You may need to run this manually:"
    Write-Host "SQL Query: $sqlQuery"
    Write-Host "Server: $sqlServer"
    Write-Host "Database: $sqlDb"
}