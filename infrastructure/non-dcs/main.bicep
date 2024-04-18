param appName string
param location string
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-plan'
  location: location
  tags: tags
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: logAnalyticsWorkspace.properties.customerId
        }
      ]
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${appName}storage'
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${appName}-logs'
  location: location
  tags: tags
  sku: {
    name: 'PerGB2018'
  }
}

resource webAppDiagnosticLogs 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${webApp.name}/logs'
  properties: {
    applicationLogs: {
      azureBlobStorage: {
        level: 'Information'
        retentionInDays: 30
        sasUrl: storageAccount.listServiceSas().serviceSasToken
      }
    }
    httpLogs: {
      azureBlobStorage: {
        enabled: true
        retentionInDays: 30
        sasUrl: storageAccount.listServiceSas().serviceSasToken
      }
    }
    detailedErrorMessages: {
      enabled: true
    }
    failedRequestsTracing: {
      enabled: true
    }
  }
}

output webAppUrl string = webApp.properties.defaultHostName
output storageAccountName string = storageAccount.name
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
