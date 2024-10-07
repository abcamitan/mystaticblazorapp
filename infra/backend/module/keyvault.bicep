param location string = resourceGroup().location
param keyVaultName string
param skuName string = 'standard'

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    enableRbacAuthorization: true
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}
