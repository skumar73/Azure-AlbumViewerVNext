# Managed Identity Implementation Plan for AlbumViewer

## Goal

Add a managed identity (as defined in `parameters.json` as `albumManagedIdentity`) to the Azure infrastructure, update the API App Service to use it, and configure the SQL Server/Database to allow this identity access with `db_owner` rights.


## Steps

### 1. Managed Identity Creation


### 2. Assign Managed Identity to API App Service

  - Add a `identity` block to the `apiAppService` resource, referencing the user-assigned managed identity.
  - Pass the managed identity resource ID as a parameter if using modules.

### 3. Grant SQL Database Access to Managed Identity

  - Add a step to create a contained database user for the managed identity in the SQL database.
  - Grant `db_owner` role to this user.
  - This may require an `Azure CLI` or `ARM` deployment script resource, as Bicep/ARM cannot directly create SQL users/roles.
  - Use the managed identity's principal ID for the user creation.

### 4. Update Connection Strings

  `Server=tcp:<server>.database.windows.net,1433;Database=<db>;Authentication=Active Directory Managed Identity;`



## Answers to Open Questions



## Next Steps

1. Implement the above steps in Bicep modules.
2. Test end-to-end: deploy infra, verify identity assignment, and test DB access from the API app.

Move to docs/mi_implementation_plan.md
Let me know if you want a detailed Bicep code sample for any step, or if you have answers to the open questions above.
