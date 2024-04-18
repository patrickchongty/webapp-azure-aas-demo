# Azure App Service (and related services) IaC

This repo contains two BICEP code that deploys an Azure App Service, Azure Storage and Log Analytic Workspace.
- Non-DCS - this repo demo the way to deploy these services in an open subscription with no network restrictions
- DCS - this repo demo the way to deploy these services in our DCS environment where everything needs to be deployed within our network

To run the bicep code:
1. Open the project in VS Code
2. Install Bicep extension for VS Code - [Bicep extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)
3. Update the .bicepparam file with your values
4. Right click on the .bicep file and click on "Open Bicep Visualizer" which will then visualise your infrastructure for you
5. To deploy, right click on the .bicep file and click on "Show Deployment Pane".
6. It will then ask you to choose your subscription, resource group etc.
7. Once you have entered all the details, you can click on "Deploy" to deploy it to the resource group or "Validate" which will validate the code for you.


