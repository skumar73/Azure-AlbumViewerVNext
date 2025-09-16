import { Injectable } from "@angular/core";
import { ApplicationInsights } from "@microsoft/applicationinsights-web";

@Injectable({
    providedIn: "root",
})
export class AppInsightsService {
    private appInsights: ApplicationInsights;

    constructor() {
        const connectionString =
            (window as any).__env?.APPLICATIONINSIGHTS_CONNECTION_STRING || ""; // Load from environment variable
        if (connectionString) {
            this.appInsights = new ApplicationInsights({
                config: {
                    connectionString: connectionString,
                    enableAutoRouteTracking: true, // Automatically track route changes
                },
            });
            this.appInsights.loadAppInsights();
            this.appInsights.addTelemetryInitializer((envelope) => {
                envelope.tags["ai.cloud.role"] = "Frontend (Angular)";
            });
            this.appInsights.trackPageView();
        } else {
            console.warn("Application Insights connection string is missing.");
        }
    }

    public setUserContext(userId: string) {
        this.appInsights.setAuthenticatedUserContext(userId);
    }

    public clearUserContext() {
        this.appInsights.clearAuthenticatedUserContext();
    }

    logPageView(name?: string, uri?: string): void {
        this.appInsights.trackPageView({ name, uri });
    }

    logEvent(name: string, properties?: { [key: string]: any }): void {
        this.appInsights.trackEvent({ name }, properties);
    }

    logException(exception: Error, severityLevel?: number): void {
        this.appInsights.trackException({ exception, severityLevel });
    }
}
