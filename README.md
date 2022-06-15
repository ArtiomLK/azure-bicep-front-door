# Azure Front Door

[![DEV - Deploy Azure Resource](https://github.com/ArtiomLK/azure-bicep-front-door/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-front-door/actions/workflows/dev.orchestrator.yml)

## Instructions

### Parameter Values

| Name                         | Description                                                   | Value             | Examples                             |
| ---------------------------- | ------------------------------------------------------------- | ----------------- | ------------------------------------ |
| tags                         | Az Resources tags                                             | object            | `{ key: value }`                     |
| fd_n                         | Front Door Name                                               | string [required] |                                      |
| fd_backend_pool_n            | Front Door BackendPool names                                  | string [required] | `backend-pool-app`                   |
| fd_backend_pool_backend_addr | Front Door BackendPool Backends. Must be IPs address or FQDNs | string [required] | `app-service-name.azurewebsites.net` |

### [Reference Examples][1]

## Locally test Azure Bicep Modules

```bash
# Create an Azure Resource Group
az group create \
--name 'rg-azure-bicep-front-door' \
--location 'eastus2' \
--tags project=bicephub env=dev

# Deploy Sample Modules
az deployment group create \
--resource-group 'rg-azure-bicep-front-door' \
--mode Complete \
--template-file examples/examples.bicep
```

## Additional Resources

- Azure Front Door (FD)
- [Youtube | John Savill's | Microsoft Azure Front Door Deep Dive][2]
- Azure Web Application Firewall (WAF)
- [MS | Docs | Azure Web Application Firewall on Azure Front Door][3]

[1]: ./examples/examples.bicep
[2]: https://www.youtube.com/watch?v=DHiZbIks9i0&ab_channel=JohnSavill%27sTechnicalTraining
[3]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview
