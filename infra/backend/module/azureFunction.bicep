param env string
param location string = resourceGroup().location
param appInsightName string
param apiFunctionAppName string
param keyVaultName string
param serviceName string
param allowedOrigins array

// Key vault user role, global value for Azure
// more on that: https://docs.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli 
resource KeyVaultSecretsUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

var storageName = 'st${serviceName}${env}01'

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${serviceName}-${env}-sievo'
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    hyperV: false
    reserved: false
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightName
}

resource functionAppDeploy 'Microsoft.Web/sites@2022-09-01' = {
  name: apiFunctionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlan.id
  }
}

resource functionAppConfigDeploy 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'web'
  parent: functionAppDeploy
  properties: {
    netFrameworkVersion: 'v8.0'
    use32BitWorkerProcess: false
    cors: {
      allowedOrigins: allowedOrigins
    }
    appSettings: [
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.properties.ConnectionString
      }
      {
        name: 'AzureWebJobsStorage'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
      }
      {
        name: 'FUNCTIONS_EXTENSION_VERSION'
        value: '~4'
      }
      {
        name: 'FUNCTIONS_WORKER_RUNTIME'
        value: 'dotnet-isolated'
      }
      {
        name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
        value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
      }
      {
        name: 'WEBSITE_CONTENTSHARE'
        value: toLower(apiFunctionAppName)
      }
      {
        name: 'WEBSITE_RUN_FROM_PACKAGE'
        value: '1'
      }
    ]
    ipSecurityRestrictions: [
      {
        ipAddress: 'AzureFrontDoor.Backend'
        action: 'Allow'
        tag: 'ServiceTag'
        priority: 100
        name: 'CDN'
      }
      {
        ipAddress: '85.76.136.143/32'
        action: 'Allow'
        tag: 'Default'
        priority: 300
        name: 'My Home'
      }
      {
        ipAddress: 'Any'
        action: 'Deny'
        priority: 2147483647
        name: 'Deny all'
        description: 'Deny all access'
      }
    ]
    ipSecurityRestrictionsDefaultAction: 'Deny'
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'AzureFrontDoor.Backend'
        action: 'Allow'
        tag: 'ServiceTag'
        priority: 100
        name: 'CDN'
      }
      {
        ipAddress: '85.76.136.143/32'
        action: 'Allow'
        tag: 'Default'
        priority: 300
        name: 'My Home'
      }
      {
        ipAddress: 'Any'
        action: 'Deny'
        priority: 2147483647
        name: 'Deny all'
        description: 'Deny all access'
      }
    ]
    scmIpSecurityRestrictionsDefaultAction: 'Deny'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource clientApiFunctionAppKeyVaultAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, functionAppDeploy.name, env)
  scope: keyVault
  properties: {
    roleDefinitionId: KeyVaultSecretsUserRoleDefinition.id
    principalId: functionAppDeploy.identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    keyVault
  ]
}

output apiFunctionAppId string = functionAppDeploy.id
output apiFunctionAppPrincipalId string = functionAppDeploy.identity.principalId
