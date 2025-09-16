# Deploy Web App (manual equivalent of GitHub Actions)
# Usage: .\deploy-web.ps1

param(
    [string]$WebAppName = "kiz-albumviewer-web",
    [string]$ResourceGroup = "kiz-albumviewer-rg",
    [string]$WebProjectPath = "../src/AlbumViewerAngular"
)

# Login to Azure (interactive or with service principal)
Write-Host "Logging in to Azure..."
az login

# Build Angular app
Write-Host "Building Angular app..."
Push-Location $WebProjectPath
if (Test-Path node_modules) {
    Write-Host "node_modules exists, skipping npm install..."
}
else {
    npm ci --silent || npm install --no-audit --no-fund
}
npm run build -- --configuration=production
if (Test-Path src/web.config) {
    Copy-Item src/web.config dist/ -Force
}
Pop-Location

# Generate env.js from App Settings
Write-Host "Generating env.js from Azure App Settings..."
$settings = az webapp config appsettings list --resource-group $ResourceGroup --name $WebAppName --query "[].{n:name,v:value}" --output tsv
$apiUrl = ""
$appInsights = ""
$environment = "production"
foreach ($setting in $settings) {
    $parts = $setting -split "\t"
    if ($parts.Length -eq 2) {
        switch ($parts[0]) {
            "API_URL" { $apiUrl = $parts[1] }
            "APPLICATIONINSIGHTS_CONNECTION_STRING" { $appInsights = $parts[1] }
            "ASPNETCORE_ENVIRONMENT" { $environment = $parts[1] }
        }
    }
}
if (-not $apiUrl) { $apiUrl = "https://api-placeholder.azurewebsites.net" }
$distPath = Join-Path $WebProjectPath "dist"
if (-not (Test-Path $distPath)) { New-Item -ItemType Directory -Path $distPath | Out-Null }
$envJs = @"
(function (window) {
  window.__env = window.__env || {};
  window.__env.API_URL = '$apiUrl';
  window.__env.APPLICATIONINSIGHTS_CONNECTION_STRING = '$appInsights';
  window.__env.ENVIRONMENT = '$environment';
})(this);
"@
$envJsPath = Join-Path $distPath "env.js"
$envJs | Set-Content $envJsPath -Encoding UTF8
Write-Host "--- env.js ---"
Get-Content $envJsPath | Select-Object -First 200 | Write-Host
