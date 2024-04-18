param appName string
param location string
param tags object
param subnetId string

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-plan'
  location: location
  tags: tags
  sku: {
    name: 'P0v3'
    tier: 'Premium'
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
        {
          name: 'DBConnString'
          value: 'Server=tcp:myserver.database.windows.net,1433;Database=mydatabase;User ID=myuser;Password=mypassword;Encrypt=true;Connection Timeout=30;'
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

resource privateEndpointAppService 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: '${appName}-pe-appservice'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${appName}-pls-connection-appservice'
        properties: {
          privateLinkServiceId: appServicePlan.id
          groupIds: ['sites']
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource privateEndpointWebApp 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: '${appName}-pe-webapp'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${appName}-pls-connection-webapp'
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: ['sites']
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource privateEndpointStorage 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: '${appName}-pe-storage'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${appName}-pls-connection-storage'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

resource privateEndpointLogAnalytics 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: '${appName}-pe-loganalytics'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${appName}-pls-connection-loganalytics'
        properties: {
          privateLinkServiceId: logAnalyticsWorkspace.id
          groupIds: ['workspaces']
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
}

output webAppUrl string = webApp.properties.defaultHostName
output storageAccountName string = storageAccount.name
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
