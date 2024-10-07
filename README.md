# Blazor Starter Application

This template contains an example .NET 8 [Blazor WebAssembly](https://docs.microsoft.com/aspnet/core/blazor/?view=aspnetcore-6.0#blazor-webassembly) client application, a .NET 8 C# [Azure Functions](https://docs.microsoft.com/azure/azure-functions/functions-overview), and a C# class library with shared code.

## Pre-Requisite
1. Install [Visual Studio Code](https://code.visualstudio.com/download)
2. Install [.Net 8 SDK](https://dotnet.microsoft.com/download)
3. Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
4. Install [AZ Powershell Module](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?tabs=powershell&pivots=windows-psgallery)
5. Register new [Azure Account](https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio)
6. Install [Azure Static Web Apps CLI](https://www.npmjs.com/package/@azure/static-web-apps-cli)
7. Install [Azure Function Core Tools](https://go.microsoft.com/fwlink/?linkid=2174087)
8. Install Storage Emulator [Azurite](https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio-code%2Cblob-storage#install-azurite) extension.

## Getting Started

1. Start Azurite by going to command pallete (Ctrl + Shift + P), find and choose Azurite: Start and then press Enter.
2. In the **Api** folder, copy `local.settings.example.json` to `local.settings.json`

### Visual Studio Code with Azure Static Web Apps CLI for a better development experience (Optional)

1. Open the folder in Visual Studio Code.

2. In the VS Code terminal, run the following command to start the Static Web Apps CLI, along with the Blazor WebAssembly client application and the Functions API app:

    In the Client folder, run:
    ```bash
    dotnet run
    ```

    In the API folder, run:
    ```bash
    func start
    ```

    In another terminal, run:
    ```bash
    swa start http://localhost:5000 --api-location http://localhost:7071
    ```

    The Static Web Apps CLI (`swa`) starts a proxy on port 4280 that will forward static site requests to the Blazor server on port 5000 and requests to the `/api` endpoint to the Functions server. 

3. Open a browser and navigate to the Static Web Apps CLI's address at `http://localhost:4280`. You'll be able to access both the client application and the Functions API app in this single address. When you navigate to the "Fetch Data" page, you'll see the data returned by the Functions API app.

4. Enter Ctrl-C to stop the Static Web Apps CLI.

## Template Structure

- **Client**: The Blazor WebAssembly sample application
- **Api**: A C# Azure Functions API, which the Blazor application will call
- **Shared**: A C# class library with a shared data model between the Blazor and Functions application

## Deploy to Azure Static Web Apps

This application can be deployed to [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps), to learn how, check out [our quickstart guide](https://aka.ms/blazor-swa/quickstart).
