# Deploy API to Azure App Service (manual equivalent of GitHub Actions)
# Usage: .\deploy-api.ps1

param(
    [string]$ApiAppName = "kiz-albumviewer-api",
    [string]$ApiProjectPath = "../src/AlbumViewerNetCore/AlbumViewerNetCore.csproj"
)

# Login to Azure (interactive or with service principal)
Write-Host "Logging in to Azure..."
az login

# Restore dependencies
Write-Host "Restoring .NET dependencies..."
dotnet restore $ApiProjectPath

# Build API
Write-Host "Building API..."
dotnet build $ApiProjectPath --configuration Release --no-restore

# Run tests (if any)
Write-Host "Running tests (if any)..."
dotnet test $ApiProjectPath --configuration Release --no-build --verbosity normal

# Publish API
Write-Host "Publishing API..."
$publishDir = "./api-publish"
dotnet publish $ApiProjectPath --configuration Release --output $publishDir --no-build

# Deploy to Azure App Service
Write-Host "Deploying API to Azure App Service..."
az webapp deploy --name $ApiAppName --src-path $publishDir --type zip

# Verify API deployment
$apiUrl = "https://$ApiAppName.azurewebsites.net"
Write-Host "`n🎉 API deployment completed!"
Write-Host "📍 API deployed to: $apiUrl"
Write-Host "Waiting for deployment to complete..."
Start-Sleep -Seconds 30
Write-Host "Testing API endpoint: $apiUrl"
try {
    $response = Invoke-WebRequest -Uri $apiUrl -UseBasicParsing -TimeoutSec 15
    Write-Host "API response status: $($response.StatusCode)"
}
catch {
    Write-Host "API endpoint test failed: $_"
}
