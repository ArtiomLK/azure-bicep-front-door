targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
// Sample tags parameters
var tags = {
  project: 'bicephub'
  env: 'dev'
}

param location string = 'eastus2'
param location_bcdr string = 'centralus'
// Sample App Service Plan parameters
param plan_enable_zone_redundancy bool = false

// ------------------------------------------------------------------------------------------------
// REPLACE
// '../main.bicep' by the ref with your version, for example:
// 'br:bicephubdev.azurecr.io/bicep/modules/plan:v1'
// ------------------------------------------------------------------------------------------------

// ------------------------------------------------------------------------------------------------
// Front Door BackEnd Pool Sample
// ------------------------------------------------------------------------------------------------

// Create a Windows Sample App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  tags: tags
  name: 'plan-azure-bicep-app-service-test'
  location: location
  sku: {
    name: 'P1V2'
    tier: 'PremiumV2'
    capacity: plan_enable_zone_redundancy ? 3 : 1
  }
  properties: {
    zoneRedundant: plan_enable_zone_redundancy
  }
}

resource appA 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appA-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource appServicePlanBCDR 'Microsoft.Web/serverfarms@2021-03-01' = {
  tags: tags
  name: 'plan-bcdr-azure-bicep-app-service-test'
  location: location_bcdr
  sku: {
    name: 'P1V2'
    tier: 'PremiumV2'
    capacity: plan_enable_zone_redundancy ? 3 : 1
  }
  properties: {
    zoneRedundant: plan_enable_zone_redundancy
  }
}

resource appB 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appB-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location_bcdr
  tags: tags
  properties: {
    serverFarmId: appServicePlanBCDR.id
  }
}

// ------------------------------------------------------------------------------------------------
// Front Door Deployment Examples
// ------------------------------------------------------------------------------------------------

// module fda '../main.bicep' = {
//   name: 'fda'
//   params: {
//     tags: tags
//     fd_n: 'fda-${guid(subscription().id, resourceGroup().id, tags.env)}'
//     fd_backend_pool_n: 'backend-pool-app'
//     fd_backend_pool_backend_addr: '${appA.name}.azurewebsites.net,${appB.name}.azurewebsites.net'
//   }
// }


module fdAPremium '../main.bicep' = {
  name: 'fd-a-premium'
  params: {
    fd_n: 'fd-a-premium'
    prefix: 'bicephubapp'
    skuName: 'Premium_AzureFrontDoor'
    endpointName: take('fd-a-premium-${guid(subscription().id, resourceGroup().id, tags.env)}', 46)
    originHostName: appA.properties.defaultHostName
    privateEndpointResourceId: appA.id
    privateLinkResourceType: 'sites' // For App Service and Azure Functions, this needs to be 'sites'.
    privateEndpointLocation: location
  }
}
