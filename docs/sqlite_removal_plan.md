# SQLite Removal Plan for AlbumViewerNetCore

This plan details the steps required to fully remove SQLite support from the .NET Core backend project.

---

## 1. Remove All SQLite-Related Code

- Delete all code paths that check or use `useSqLite` or `Data:useSqLite` configuration.
- Remove all usages of `UseSqlite` and references to `AlbumViewerData.sqlite`.
- Remove any logic that switches between SQL Server and SQLite based on configuration.

## 2. Update Configuration Files

- Remove the `useSqLite` setting from `appsettings.json` and any other config files.

## 3. Update Controllers

- Remove any controller logic that checks or exposes the DB mode (e.g., `DataMode = useSqLite == "true" ? "SqLite" : "Sql Server"`).
- Remove any code that deletes or manipulates the SQLite file.

## 4. Update Project File

- Remove the NuGet package reference for `Microsoft.EntityFrameworkCore.Sqlite` from `AlbumViewerNetCore.csproj`.
- Remove any project file logic that removes or references `AlbumViewerData.sqlite`.

## 5. Clean Up

- Delete any SQLite database files (e.g., `AlbumViewerData.sqlite`) from the repo.
- Remove any documentation or comments referring to SQLite support.

## 6. Test

- Build and run the project to ensure it works with only SQL Server (and managed identity) support.
- Ensure all tests pass and the application behaves as expected.

---

**After these steps, the project will only support SQL Server as the backend.**
