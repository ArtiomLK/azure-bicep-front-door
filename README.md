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

## Logs

```java (Kusto)
// Count responses filtered by http codes
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where toint(httpStatusCode_s) >= 200
| extend ParsedUrl = parseurl(requestUri_s)
| summarize RequestCount = count() by Host = tostring(ParsedUrl.Host), StatusCode = httpStatusCode_s
| order by RequestCount desc

// Count responses filtered by http codes, request uri path and http method
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where toint(httpStatusCode_s) >= 200
| where requestUri_s has 'some-path.aspx'
| where httpMethod_s has 'POST'
| extend ParsedUrl = parseurl(requestUri_s)
| summarize RequestCount = count() by Host = tostring(ParsedUrl.Host), StatusCode = httpStatusCode_s, requestUri_s
| order by RequestCount desc

// Display Log details filtered by http codes, request uri path, http method and IP
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where toint(httpStatusCode_s) <= 500
| where requestUri_s has 'some-path.aspx'
| where httpMethod_s has 'POST'
| where clientIp_s has '###.###.###.###'
| extend localTimestamp = TimeGenerated - 6h
| extend ParsedUrl = parseurl(requestUri_s)

// Display server errors filtered by http codes, request uri path, http method and IP
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where toint(httpStatusCode_s) >= 500
| where requestUri_s has 'some-path.aspx'
| where httpMethod_s has 'POST'
| where clientIp_s has '###.###.###.###'
| extend ParsedUrl = parseurl(requestUri_s)
| extend localTimestamp = TimeGenerated - 6h
| project localTimestamp, RequestBytes = toint(requestBytes_s), ResponseBytes = toint(responseBytes_s), clientIp_s, httpStatusCode_s, timeToFirstByte_s, ErrorInfo_s, clientCountry_s

// Display Server Error count by IPs filtered by http codes, request uri path, http method and IP
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where toint(httpStatusCode_s) >= 500
// | where requestUri_s has 'some-path.aspx'
| where httpMethod_s has 'POST'
// | where clientIp_s has '###.###.###.###'
| extend ParsedUrl = parseurl(requestUri_s)
| summarize RequestCount = count() by clientIp_s, clientCountry_s
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
- [MS | Docs | Tuning Web Application Firewall (WAF) for Azure Front Door][8]
- [MS | Docs | Web Application Firewall DRS (Default Rule Set) rule groups and rules][7]
- Microsoft Sentinel
- [MS | Docs | Using Microsoft Sentinel with Azure Web Application Firewall][10]

[1]: ./examples/examples.bicep
[2]: https://www.youtube.com/watch?v=DHiZbIks9i0&ab_channel=JohnSavill%27sTechnicalTraining
[3]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-faq
[4]: https://docs.microsoft.com/en-us/azure/frontdoor/private-link
[5]: https://docs.microsoft.com/en-us/azure/private-link/private-link-faq
[6]: https://docs.microsoft.com/en-us/azure/private-link/private-link-service-overview
[7]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-drs
[8]: https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-tuning
[9]: https://docs.microsoft.com/en-us/azure/frontdoor/troubleshoot-issues
[10]: https://docs.microsoft.com/en-us/azure/web-application-firewall/waf-sentinel
