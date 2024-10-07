param serviceName string
param principalId string
param principalType string
param location string = resourceGroup().location
param environment string = 'dev'
param storageAccountName string = 'st${serviceName}${environment}01'
param cdnProfileName string = 'cdn-${serviceName}-${environment}'
param cdnEndpointName string = 'cdn-endpoint-${serviceName}-${environment}'

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
    cdnProfileName: cdnProfileName
    storagePrimaryEndpointWeb: storage.outputs.storagePrimaryEndpointWeb
    cdnEndpointName: cdnEndpointName
  }
}
