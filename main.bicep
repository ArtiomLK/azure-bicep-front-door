// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
@description('Az Resources tags')
param tags object = {}

// ------------------------------------------------------------------------------------------------
// FD Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('Front Door Name')
@maxLength(64)
param fd_n string

@description('Front Door tier')
@maxLength(64)
param fd_tier string

@description('Front Door BackendPool names')
param fd_backend_pool_n string

@description('Front Door BackendPool Backends. Must be an IP address or FQDN')
param fd_backend_pool_backend_addr string
var fd_backend_pool_backend_addr_parsed = split(fd_backend_pool_backend_addr, ',')

var frontEndEndpointName = 'frontEndEndpoint'
var loadBalancingSettingsName = 'loadBalancingSettings'
var healthProbeSettingsName = 'healthProbeSettings'
var routingRuleName = 'routingRule'

// ------------------------------------------------------------------------------------------------
// Deploy FD
// ------------------------------------------------------------------------------------------------
resource frontdoor 'Microsoft.Network/frontDoors@2019-05-01' = {
  name: fd_n
  tags: tags
  location: 'global'
  properties: {
    frontendEndpoints: [
      {
        name: frontEndEndpointName
        properties: {
          hostName: '${fd_n}.azurefd.net'
          sessionAffinityEnabledState: 'Disabled'
        }
      }
    ]

    loadBalancingSettings: [
      {
        name: loadBalancingSettingsName
        properties: {
          sampleSize: 4
          successfulSamplesRequired: 2
        }
      }
    ]

    healthProbeSettings: [
      {
        name: healthProbeSettingsName
        properties: {
          path: '/'
          protocol: 'Http'
          intervalInSeconds: 120
        }
      }
    ]

    backendPools: [
      {
        name: fd_backend_pool_n
        properties: {
          backends: [for i in range(0, length(fd_backend_pool_backend_addr_parsed)): {

              address: fd_backend_pool_backend_addr_parsed[i]
              backendHostHeader: fd_backend_pool_backend_addr_parsed[i]
              httpPort: 80
              httpsPort: 443
              weight: 50
              priority: 1
              enabledState: 'Enabled'
            }]
          loadBalancingSettings: {
            id: resourceId('Microsoft.Network/frontDoors/loadBalancingSettings', fd_n, loadBalancingSettingsName)
          }
          healthProbeSettings: {
            id: resourceId('Microsoft.Network/frontDoors/healthProbeSettings', fd_n, healthProbeSettingsName)
          }
        }
      }
    ]

    routingRules: [
      {
        name: routingRuleName
        properties: {
          frontendEndpoints: [
            {
              id: resourceId('Microsoft.Network/frontDoors/frontEndEndpoints', fd_n, frontEndEndpointName)
            }
          ]
          acceptedProtocols: [
            'Http'
            'Https'
          ]
          patternsToMatch: [
            '/*'
          ]
          routeConfiguration: {
            '@odata.type': '#Microsoft.Azure.FrontDoor.Models.FrontdoorForwardingConfiguration'
            forwardingProtocol: 'MatchRequest'
            backendPool: {
              id: resourceId('Microsoft.Network/frontDoors/backEndPools', fd_n, fd_backend_pool_n)
            }
          }
          enabledState: 'Enabled'
        }
      }
    ]
  }
}

output id string = frontdoor.id
