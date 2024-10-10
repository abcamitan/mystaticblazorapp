param serviceName string
param environment string
param apiFunctionAppName string
param location string = resourceGroup().location
param appInsightName string
param keyVaultName string
param cdnEndpointName string

module appInsightDeploy 'module/appInsight.bicep' = {
  name: appInsightName
  params: {
    location: location
    appInsightsName: appInsightName
  }
}

module keyVaultDeploy 'module/keyvault.bicep' = {
  name: keyVaultName
  params: {
    location: location
    keyVaultName: keyVaultName
  }
}

module functionAppDeploy 'module/azureFunction.bicep' = {
  name: apiFunctionAppName
  params: {
    env: environment
    location: location
    appInsightName: appInsightName
    apiFunctionAppName: apiFunctionAppName
    keyVaultName: keyVaultName
    serviceName: serviceName
    allowedOrigins: [
      'https://${cdnEndpointName}.azureedge.net'
    ]
  }
  dependsOn: [
    appInsightDeploy
    keyVaultDeploy
  ]
}
