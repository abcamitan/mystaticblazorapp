param (
    [string]$serviceName = "myblazorapp",
    [string]$environment = "dev",
    [string]$location = "westeurope",
    [string]$frontendProjectPath = "./Client/Client.csproj",
    [string]$backendProjectPath = "./Api/Api.csproj",
    [string]$sharedProjectPath = "./Shared/Shared.csproj",
    [string]$buildOutputPath = "./Api/bin/Release/output",
    [string]$webbuildOutputPath = "./Client/bin/Release/publish",
    [string]$principalId = "2915fc04-7324-45c1-8be7-e1f7bd2befc9",
    [string]$principalType = "Group"
)

az login

$resourceGroupName = "rg-$($serviceName)-$($environment)"
$storageAccountName = "st$($serviceName)$($environment)01"
$cdnProfileName = "cdn-$($serviceName)-$($environment)"
$cdnEndpointName = "cdn-endpoint-$($serviceName)-$($environment)"
$apiFunctionAppName = "func-$($serviceName)-$($environment)-v1"
$appInsightName = "appinsight-$($serviceName)-$($environment)"
$keyVaultName = "kv-$($serviceName)-$($environment)"

# Check if the resource group exists
$resourceGroupExists = az group exists --name $resourceGroupName

# Create the resource group if it does not exist
if ($resourceGroupExists -eq 'false') {
    az group create --name $resourceGroupName --location $location
}

# Register the Microsoft.AlertsManagement namespace
az provider register --namespace Microsoft.AlertsManagement

# Wait for the Microsoft.AlertsManagement to be registered
Start-Sleep -Seconds 30

# Verify the registration status
$registrationStatus = az provider show --namespace Microsoft.AlertsManagement --query "registrationState" --output tsv

if ($registrationStatus -ne "Registered") {
    throw "Failed to register the Microsoft.AlertsManagement namespace. Current status: $registrationStatus"
}

# deploy the backend infrastructure
az deployment group create --resource-group $resourceGroupName --template-file "./infra/backend/main.bicep" --parameters serviceName=$serviceName environment=$environment apiFunctionAppName=$apiFunctionAppName appInsightName=$appInsightName keyVaultName=$keyVaultName

# Build the API app
& dotnet publish $backendProjectPath -c Release -o "$($buildOutputPath)\publish"
& dotnet publish $sharedProjectPath -c Release -o "$($buildOutputPath)\publish"

# Package path for the zip file
$packagePath = "$($buildOutputPath)\package"

# Create the package directory if it doesn't exist
if (-Not (Test-Path -Path $packagePath)) {
    New-Item -ItemType Directory -Path $packagePath
}

# Define the output zip file path
$zipFilePath = "$($packagePath)\package.zip"

# Create a zip package of the published output
Compress-Archive -Path "$($buildOutputPath)\publish\*" -DestinationPath $zipFilePath -Force

# Wait for the Function App to be deployed
Start-Sleep -Seconds 30

# Deploy the zip package to Azure Function App
# (Assuming you have already created the Function App using Bicep or other means)
az functionapp deployment source config-zip -g $resourceGroupName -n $apiFunctionAppName --src $zipFilePath

# deploy the frontend infrastructure
az deployment group create --resource-group $resourceGroupName --template-file "./infra/frontend/main.bicep" --parameters serviceName=$serviceName environment=$environment storageAccountName=$storageAccountName cdnProfileName=$cdnProfileName cdnEndpointName=$cdnEndpointName principalId=$principalId principalType=$principalType

# Enable the static website feature on the storage account
az storage blob service-properties update --static-website --index-document "index.html" --404-document "index.html" --account-name $storageAccountName

# Wait for the static website feature to be enabled
Start-Sleep -Seconds 30

# Build the Blazor WebAssembly app
& dotnet publish $frontendProjectPath -c Release -o $webbuildOutputPath -p:CompressionEnabled=false
& dotnet publish $sharedProjectPath -c Release -o $webbuildOutputPath

# Get the storage account key
$storageAccountKey = (az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query "[0].value" --output tsv)

# Upload files to the storage account
az storage blob upload-batch -d '$web' --account-name $storageAccountName --account-key $storageAccountKey -s "$($webbuildOutputPath)/wwwroot" --overwrite

# Purge the CDN endpoint
az cdn endpoint purge --resource-group $resourceGroupName --profile-name $cdnProfileName --name $cdnEndpointName --content-paths "/*" --no-wait
