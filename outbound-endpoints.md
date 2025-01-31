<!--THIS CODE AND ANY ASSOCIATED INFORMMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.-->

# Required Outbound Endpoints for Azure Government Function App

## Mandatory Core Platform Endpoints
These endpoints are required for basic Function App operation:

### Runtime Dependencies
- `functions.azurewebsites.us` - Function runtime communication
- `scm.azurewebsites.us` - Kudu/SCM site for deployments
- `oryxprodscusdf.blob.core.usgovcloudapi.net` - Oryx builder platform

### Storage Dependencies (Required)
- `*.core.usgovcloudapi.net` - Azure Storage account access required for function app
  - Primary storage account for function app
  - Any additional storage accounts used by your functions

### Monitoring (Required for basic operation)
- `monitor.azure.us` - Basic platform monitoring
- `applicationinsights.us` - Application Insights if enabled

## Optional Service-Specific Endpoints
Only needed if your function app uses these services:

### Azure AI Services (Optional)
Only required if using specific AI services:
- `[your-resource-name].cognitiveservices.azure.us` - For Azure AI services
- `[your-resource-name].openai.azure.us` - For Azure OpenAI

### Data Services (Optional)
Only required if your functions interact with these services:
- `documents.azure.us` - For Cosmos DB connections
- `vault.usgovcloudapi.net` - For Key Vault access

### Azure Machine Learning (Optional)
Only if using Azure ML:
- `ml.azure.us`
- `[workspace-name].api.ml.azure.us`

## Network Security Configuration

### NSG Rule Priority
1. Allow outbound to mandatory endpoints (highest priority)
2. Allow outbound to required service-specific endpoints
3. Deny all other outbound traffic (lowest priority)

### Implementation Notes
1. Must allow outbound TCP on ports 443 (HTTPS) and 80 (HTTP)
2. For storage endpoints, use wildcard to cover all storage account URLs
3. Consider using Azure Service Tags where available:
   - `AzureCloud.usgovtexas` 
   - `AzureCloud.usgovvirginia`

### Best Practices
1. Start with mandatory endpoints only
2. Add service-specific endpoints as needed
3. Use monitoring to identify missing required endpoints
4. Regularly review and remove unused endpoint access
5. Document any additional endpoints specific to your application

## Validation Steps
1. Deploy function app with minimal outbound access
2. Monitor Application Insights for any connection failures
3. Check function app logs for connectivity issues
4. Test each function trigger type
5. Validate service-specific connectivity as needed

Reference: https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings
Reference: https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-networking
