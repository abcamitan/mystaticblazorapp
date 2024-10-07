param env string
param storageAccountName string
param principalId string
param principalType string
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            '*'
          ]
          allowedMethods: [
            'GET'
          ]
          allowedHeaders: [
            'Content-Type'
          ]
          exposedHeaders: [
            'Content-Type'
          ]
          maxAgeInSeconds: 200
        }
      ]
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 30
    }
  }
}

resource blobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
}

resource blobContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('blob${env}${principalId}${storageAccountName}')
  scope: storageAccount
  properties: {
    principalId: principalId
    roleDefinitionId: blobDataContributorRoleDefinition.id
    principalType: principalType
  }
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output storageAccountApiVersion string = storageAccount.apiVersion
output storagePrimaryEndpointWeb string = storageAccount.properties.primaryEndpoints.web
