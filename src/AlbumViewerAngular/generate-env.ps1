# Generate env.js from Azure App Service environment variables
# This script runs on startup to create the environment configuration for the Angular app

param(
    [string]$SourcePath = "D:\home\site\wwwroot\env.js.template",
    [string]$TargetPath = "D:\home\site\wwwroot\env.js"
)

Write-Host "Generating env.js from environment variables..."
Write-Host "Source template: $SourcePath"
Write-Host "Target file: $TargetPath"

try {
    # Read the template file
    if (Test-Path $SourcePath) {
        $template = Get-Content $SourcePath -Raw
        Write-Host "Template file found and loaded"
    } else {
        Write-Host "Template file not found at: $SourcePath"
        # Create a basic template if not found
        $template = @"
(function (window) {
  window.__env = window.__env || {};
  window.__env.API_URL = '`${API_URL}';
  window.__env.APPLICATIONINSIGHTS_CONNECTION_STRING = '`${APPLICATIONINSIGHTS_CONNECTION_STRING}';
  window.__env.ENVIRONMENT = '`${ENVIRONMENT}' || 'production';
})(this);
"@
        Write-Host "Using fallback template"
    }

    # Get environment variables with fallbacks
    $apiUrl = $env:API_URL
    if (-not $apiUrl) {
        $apiUrl = "https://api-placeholder.azurewebsites.net"
        Write-Host "API_URL not found, using placeholder: $apiUrl"
    } else {
        Write-Host "API_URL found: $apiUrl"
    }

    $appInsightsConnectionString = $env:APPLICATIONINSIGHTS_CONNECTION_STRING
    if (-not $appInsightsConnectionString) {
        $appInsightsConnectionString = ""
        Write-Host "APPLICATIONINSIGHTS_CONNECTION_STRING not found"
    } else {
        Write-Host "APPLICATIONINSIGHTS_CONNECTION_STRING found: $($appInsightsConnectionString.Substring(0, [Math]::Min(50, $appInsightsConnectionString.Length)))..."
    }

    $environment = $env:ASPNETCORE_ENVIRONMENT
    if (-not $environment) {
        $environment = "production"
        Write-Host "ASPNETCORE_ENVIRONMENT not found, using: $environment"
    } else {
        Write-Host "ASPNETCORE_ENVIRONMENT found: $environment"
    }

    # Replace placeholders in template
    $envContent = $template
    $envContent = $envContent.Replace('${API_URL}', $apiUrl)
    $envContent = $envContent.Replace('${APPLICATIONINSIGHTS_CONNECTION_STRING}', $appInsightsConnectionString)
    $envContent = $envContent.Replace('${ENVIRONMENT}', $environment)

    # Write the generated file
    $envContent | Out-File -FilePath $TargetPath -Encoding UTF8 -Force
    Write-Host "Successfully generated env.js at: $TargetPath"
    
    # Verify the file was created
    if (Test-Path $TargetPath) {
        $fileSize = (Get-Item $TargetPath).Length
        Write-Host "File created successfully. Size: $fileSize bytes"
    } else {
        Write-Host "ERROR: File was not created successfully"
        exit 1
    }

} catch {
    Write-Host "ERROR generating env.js: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}

Write-Host "env.js generation completed successfully"