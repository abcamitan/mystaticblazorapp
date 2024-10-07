param location string = resourceGroup().location
param storagePrimaryEndpointWeb string
param cdnProfileName string
param cdnEndpointName string

var storageAccountHostName = replace(replace(storagePrimaryEndpointWeb, 'https://', ''), '/', '')

resource cdnProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: cdnProfileName
  location: location
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2023-05-01' = {
  name: cdnEndpointName
  location: location
  parent: cdnProfile
  properties: {
    queryStringCachingBehavior: 'IgnoreQueryString'
    originHostHeader: storageAccountHostName
    origins: [
      {
        name: 'primaryOrigin'
        properties: {
          hostName: storageAccountHostName
        }
      }
    ]
    isCompressionEnabled: true
    contentTypesToCompress: [
      'application/eot'
      'application/font'
      'application/font-sfnt'
      'application/javascript'
      'application/json'
      'application/opentype'
      'application/otf'
      'application/pkcs7-mime'
      'application/truetype'
      'application/ttf'
      'application/vnd.ms-fontobject'
      'application/xhtml+xml'
      'application/xml'
      'application/xml+rss'
      'application/x-font-opentype'
      'application/x-font-truetype'
      'application/x-font-ttf'
      'application/x-httpd-cgi'
      'application/x-javascript'
      'application/x-mpegurl'
      'application/x-opentype'
      'application/x-otf'
      'application/x-perl'
      'application/x-ttf'
      'font/eot'
      'font/ttf'
      'font/otf'
      'font/opentype'
      'image/svg+xml'
      'text/css'
      'text/csv'
      'text/html'
      'text/javascript'
      'text/js'
      'text/plain'
      'text/richtext'
      'text/tab-separated-values'
      'text/xml'
      'text/x-script'
      'text/x-component'
      'text/x-java-source'
    ]
  }
}

resource endpointOrigins 'Microsoft.Cdn/profiles/endpoints/origins@2023-05-01' = {
  name: 'primaryOrigin'
  parent: cdnEndpoint
  properties: {
    hostName: storageAccountHostName
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
    enabled: true
  }
}

output staticWebsiteUrl string = 'https://${cdnEndpoint.name}.azureedge.net'
