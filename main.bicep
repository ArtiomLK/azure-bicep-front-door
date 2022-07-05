// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
@description('Az Resources tags')
param tags object = {}

// ------------------------------------------------------------------------------------------------
// FD Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('The Azure Front Door Name')
param fd_n string

param route_n string

param origin_g_n string

@description('The name of the Front Door endpoint to create. This must be globally unique.')
param endpoint_n string

@description('The name of the SKU to use when creating the Front Door profile. If you use Private Link this must be set to `Premium_AzureFrontDoor`.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param sku_n string

@description('The host name that should be used when connecting to the origin.')
param origin_host_names array

@description('The path that should be used when connecting to the origin.')
param origin_path string = ''

@description('The protocol that should be used when connecting from Front Door to the origin.')
@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
param origin_fw_protocol string = 'HttpsOnly'

@description('The protocol that should be used when checking origin health from Front Door to origins')
@allowed([
  'Http'
  'Https'
])
param origin_gr_health_probe_settings string

@description('If you are using Private Link to connect to the origin, this should specify the resource ID of the Private Link resource (e.g. an App Service application, Azure Storage account, etc). If you are not using Private Link then this should be empty.')
param pe_res_ids array

@description('If you are using Private Link to connect to the origin, this should specify the resource type of the Private Link resource. The allowed value will depend on the specific Private Link resource type you are using. If you are not using Private Link then this should be empty.')
param pl_res_types array

@description('If you are using Private Link to connect to the origin, this should specify the location of the Private Link resource. If you are not using Private Link then this should be empty.')
param pe_l array

// When connecting to Private Link origins, we need to assemble the privateLinkOriginDetails object with various pieces of data.
var isPrivateLinkOrigins = [for privateEndpointResourceId in pe_res_ids : (privateEndpointResourceId != '') ]

var privateLinkOriginDetails = [for i in range(0, length(pe_res_ids)) : {
  privateLink: {
    id: pe_res_ids[i]
  }
  groupId: (pl_res_types[i] != '') ? pl_res_types[i] : null
  privateLinkLocation: pe_l[i]
  requestMessage: 'Please approve this connection.'
}]

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: fd_n
  location: 'global'
  tags: tags
  sku: {
    name: sku_n
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: endpoint_n
  parent: profile
  location: 'global'
  tags: tags
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: origin_g_n
  parent: profile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: origin_gr_health_probe_settings
      probeIntervalInSeconds: 100
    }
  }
}

resource origins 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = [ for i in range(0, length(origin_host_names)) : {
  name: replace(origin_host_names[i], '.azurewebsites.net', '')
  parent: originGroup
  properties: {
    hostName: origin_host_names[i]
    httpPort: 80
    httpsPort: 443
    originHostHeader: origin_host_names[i]
    priority: 1
    weight: 1000
    sharedPrivateLinkResource: isPrivateLinkOrigins[i] ? privateLinkOriginDetails[i] : null
  }
}]

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: route_n
  parent: endpoint
  dependsOn: [
    origins // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    originGroup: {
      id: originGroup.id
    }
    origin_path: origin_path != '' ? origin_path : null
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    cacheConfiguration: {
      queryStringCachingBehavior: 'IgnoreQueryString'
    }
    forwardingProtocol: origin_fw_protocol
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointHostName string = endpoint.properties.hostName
output id string = profile.properties.frontDoorId
