using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;

public class CloudRoleNameInitializer : ITelemetryInitializer
{
    //https://learn.microsoft.com/en-us/azure/azure-monitor/app/api-filtering-sampling?tabs=dotnet%2Cjavascriptwebsdkloaderscript#net-applications-1
    public void Initialize(ITelemetry telemetry)
    {
        telemetry.Context.Cloud.RoleName = "Backend (NetCore)";
    }
}
