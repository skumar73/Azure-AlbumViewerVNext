// generate-env.js - Node.js script to generate env.js from environment variables
// This runs on Azure App Service startup

const fs = require('fs');
const path = require('path');

console.log('Generating env.js from environment variables...');

// Template content
const template = `// Environment variables exposed to the Angular application
// This file is generated automatically from Azure App Service environment variables
(function (window) {
  window.__env = window.__env || {};
  
  // API endpoint URL
  window.__env.API_URL = '{{API_URL}}';
  
  // Application Insights connection string
  window.__env.APPLICATIONINSIGHTS_CONNECTION_STRING = '{{APPLICATIONINSIGHTS_CONNECTION_STRING}}';
  
  // Environment type
  window.__env.ENVIRONMENT = '{{ENVIRONMENT}}' || 'production';
  
})(this);`;

try {
  // Get environment variables with fallbacks
  const apiUrl = process.env.API_URL || 'https://api-placeholder.azurewebsites.net';
  const appInsightsConnectionString = process.env.APPLICATIONINSIGHTS_CONNECTION_STRING || '';
  const environment = process.env.ASPNETCORE_ENVIRONMENT || 'production';

  console.log('API_URL:', apiUrl);
  console.log('APPLICATIONINSIGHTS_CONNECTION_STRING:', appInsightsConnectionString ? 'Found' : 'Not found');
  console.log('ENVIRONMENT:', environment);

  // Replace placeholders in template
  let envContent = template
    .replace('{{API_URL}}', apiUrl)
    .replace('{{APPLICATIONINSIGHTS_CONNECTION_STRING}}', appInsightsConnectionString)
    .replace('{{ENVIRONMENT}}', environment);

  // Write the generated file
  const outputPath = path.join(__dirname, 'env.js');
  fs.writeFileSync(outputPath, envContent, 'utf8');
  
  console.log('Successfully generated env.js at:', outputPath);
  console.log('File size:', fs.statSync(outputPath).size, 'bytes');

} catch (error) {
  console.error('ERROR generating env.js:', error.message);
  process.exit(1);
}

console.log('env.js generation completed successfully');