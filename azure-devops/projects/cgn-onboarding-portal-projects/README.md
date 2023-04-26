## How to renew azure service princials credentials

```sh
az account set -s PROD-IO
terraform apply -replace="azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL"
terraform apply -replace="azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL"
terraform apply -replace="azuredevops_serviceendpoint_azurecr.cgnonboardingportal-uat-azurecr"
terraform apply -replace="azuredevops_serviceendpoint_azurecr.cgnonboardingportal-prod-azurecr"
```
