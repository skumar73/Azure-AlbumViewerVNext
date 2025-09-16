@description('User-assigned managed identity for AlbumViewer API')
param albumManagedIdentity string
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: albumManagedIdentity
  location: location
}

@description('Resource ID of the managed identity')
output managedIdentityResourceId string = managedIdentity.id

@description('Principal ID of the managed identity')
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
