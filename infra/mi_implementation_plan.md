# Managed Identity Implementation Plan for AlbumViewer

## Goal

Add a managed identity (as defined in `parameters.json` as `albumManagedIdentity`) to the Azure infrastructure, update the API App Service to use it, and configure the SQL Server/Database to allow this identity access with `db_owner` rights.

---

## Steps

### 1. Managed Identity Creation

- Add a new resource to the Bicep infrastructure (likely in a new or existing `managed-identity.bicep` module) to create a user-assigned managed identity named from the `albumManagedIdentity` parameter.
- Output the managed identity's resource ID and principal ID for use in other modules.

### 2. Assign Managed Identity to API App Service

- Update `app-service-api.bicep`:
  - Add a `identity` block to the `apiAppService` resource, referencing the user-assigned managed identity.
  - Pass the managed identity resource ID as a parameter if using modules.

### 3. Grant SQL Database Access to Managed Identity

- Update `sql-server.bicep`:
  - Add a step to create a contained database user for the managed identity in the SQL database.
  - Grant `db_owner` role to this user.
  - This may require an `Azure CLI` or `ARM` deployment script resource, as Bicep/ARM cannot directly create SQL users/roles.
  - Use the managed identity's principal ID for the user creation.

### 4. Update Connection Strings

- The Bicep deployment sets the SQL connection string using SQL authentication for initial setup and debugging.
- To use managed identity, you must update the `Data__SqlServerConnectionString` app setting after deployment to use the format:
  `Server=tcp:<server>.database.windows.net,1433;Database=<db>;Authentication=Active Directory Managed Identity;`
- Leave the SQL admin password in app settings for debugging purposes, as this is a demonstration project.

---

---

## Answers to Open Questions

- **Does the SQL Server have Azure AD authentication enabled?** Yes.
- **Is the managed identity already used elsewhere?** No, a new one will be created.
- **Should the web app also use the managed identity?** No, it only calls the API App’s REST endpoint.
- **Should the SQL admin password be removed from the app settings after migration?** No, leave it for debugging.
- **Is there a Key Vault in use for secrets?** No, do not use Key Vault for this demonstration project.

---

## Next Steps

1. Implement the above steps in Bicep modules.
2. Test end-to-end: deploy infra, verify identity assignment, and test DB access from the API app.

---

Let me know if you want a detailed Bicep code sample for any step, or if you have answers to the open questions above.
