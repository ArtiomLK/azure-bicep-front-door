# Azure Front Door

[![DEV - Deploy Azure Resource](https://github.com/ArtiomLK/azure-bicep-front-door/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-front-door/actions/workflows/dev.orchestrator.yml)

## Instructions

### Parameter Values

| Name                            | Description                                                                                                                                             | Value             | Examples                                                                                  |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- | ----------------------------------------------------------------------------------------- |
| tags                            | Az Resources tags                                                                                                                                       | object            | `{ key: value }`                                                                          |
| fd_n                            | Front Door Name                                                                                                                                         | string [required] |                                                                                           |
| route_n                         | Front Door Route Name                                                                                                                                   | string [required] |                                                                                           |
| origin_g_n                      | Front Door Origin Group Name                                                                                                                            | string [required] |                                                                                           |
| endpoint_n                      | Front Door Endpoint Name                                                                                                                                | string [required] |                                                                                           |
| sku_n                           | Front Door SKU                                                                                                                                          | string [required] | `Standard_AzureFrontDoor`            \| `Premium_AzureFrontDoor`                          |
| origin_host_names               | The host name that should be used when connecting to the origin                                                                                         | string [required] |                                                                                           |
| origin_path                     | The path that should be used when connecting to the origin                                                                                              |                   |                                                                                           |
| origin_fw_protocol              | The protocol that should be used when connecting from Front Door to the origin                                                                          |                   |                                                                                           |
| origin_gr_health_probe_settings | The protocol that should be used when checking origin health from Front Door to origins                                                                 |                   |                                                                                           |
| pe_res_ids                      | If using Private Link to connect to the origin, this should specify the resource ID of the Private Link resource. Otherwise, this should be empty       | string [required] | `an App Service res ID, Azure Storage account res ID, etc.`                               |
| pl_res_types                    | If using Private Link to connect to the origin, this should specify the resource type of the Private Link resource. Otherwise, this should be empty     | string [required] | `The allowed value will depend on the specific Private Link resource type you are using.` |
| pe_l                            | If you are using Private Link to connect to the origin, this should specify the location of the Private Link resource. Otherwise, this should be empty. | string [required] |                                                                                           |

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
- Azure Front Door with Private Link
- [MS | Docs | Secure your Origin with Private Link in Azure Front Door Premium][4]
- [MS | Docs | Azure Private Link frequently asked questions (FAQ)][5]
- [MS | Docs | What is Azure Private Link service?][6]
- Azure Web Application Firewall (WAF)
- [MS | Docs | Frequently asked questions for Azure Web Application Firewall on Azure Front Door Service][3]
- [MS | Docs | Troubleshoot Azure Front Door common issues][9]
- [MS | Docs | Tuning Web Application Firewall (WAF) for Azure Front Door][3]
- [MS | Docs | Web Application Firewall DRS (Default Rule Set) rule groups and rules][8]

[1]: ./examples/examples.bicep
[2]: https://www.youtube.com/watch?v=DHiZbIks9i0&ab_channel=JohnSavill%27sTechnicalTraining
[3]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-faq
[4]: https://docs.microsoft.com/en-us/azure/frontdoor/private-link
[5]: https://docs.microsoft.com/en-us/azure/private-link/private-link-faq
[6]: https://docs.microsoft.com/en-us/azure/private-link/private-link-service-overview
[7]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-drs
[8]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning
[9]: https://docs.microsoft.com/en-us/azure/frontdoor/troubleshoot-issues
