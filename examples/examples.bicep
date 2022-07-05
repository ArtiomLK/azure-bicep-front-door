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

resource appB 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appB-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
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

resource appC 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appC-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location_bcdr
  tags: tags
  properties: {
    serverFarmId: appServicePlanBCDR.id
  }
}

module fdAPremium '../main.bicep' = {
  name: 'fd-a-premium'
  params: {
    fd_n: 'fd-a-premium'
    skuName: 'Premium_AzureFrontDoor'
    endpointName: take('fd-a-premium-${guid(subscription().id, resourceGroup().id, tags.env)}', 46)
    routeName: 'myapp-prod-route'
    originGroupName: 'myapp-prod-origin-group'
    originGroupHealthProbeSettings: 'Https'
    originHostNames: [appA.properties.defaultHostName, appB.properties.defaultHostName, appC.properties.defaultHostName]
    privateEndpointResourceIds: [appA.id, '', appC.id]
    privateLinkResourceType: ['sites', '', 'sites'] // For App Service and Azure Functions, this needs to be 'sites'.
    privateEndpointLocations: [location, location, location_bcdr]
  }
}
