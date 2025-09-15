# Simple Bicep deployment test script
# Deploy AlbumViewer infrastructure to Azure

# Set your subscription ID here
$subscriptionId = "f78f59ad-cf27-4eff-8f5e-6f97b34798aa"

# Set the subscription
az account set --subscription $subscriptionId

# Deploy the infrastructure
az deployment sub create `
    --location eastus2 `
    --template-file infra/main.bicep `
    --parameters @infra/parameters.json