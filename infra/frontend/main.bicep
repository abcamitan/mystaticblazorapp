param principalId string
param principalType string
param location string = resourceGroup().location
param environment string
param storageAccountName string
param cdnProfileName string
param cdnEndpointName string
param apiFunctionAppName string

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    env: environment
    location: location
    storageAccountName: storageAccountName
    principalId: principalId
    principalType: principalType
  }
}

module cdn 'modules/cdn.bicep' = {
  name: 'cdn'
  params: {
    location: location
    env: environment
    cdnProfileName: cdnProfileName
    storagePrimaryEndpointWeb: storage.outputs.storagePrimaryEndpointWeb
    cdnEndpointName: cdnEndpointName
    apiFunctionAppName: apiFunctionAppName
  }
}
