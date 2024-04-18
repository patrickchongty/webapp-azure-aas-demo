using './main.bicep'

param location = 'australiaeast'
param tags = { ENV: 'DEV'}
param appName = 'your-azure-app-service-name'
param subnetId = 'your-subnet-id-in-the-format-below'
// param subnetId = '/subscriptions/{subscription-id}}/resourceGroups/{resource-group-name}}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{subnet-name}'

