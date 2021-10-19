module "secrets" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v1.0.11"

  resource_group = "io-p-rg-operations"
  key_vault_name = "io-p-kv-azuredevops"

  secrets = [
    "DANGER-GITHUB-API-TOKEN",
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "io-azure-devops-github-USERNAME",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-SELFCARE-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID",
    "dev-selc-aks-apiserver-url",
    "dev-selc-aks-azure-devops-sa-token",
    "dev-selc-aks-azure-devops-sa-cacrt",
/* TODO uncomment when aks UAT will be available
    "uat-selc-aks-apiserver-url",
    "uat-selc-aks-azure-devops-sa-token",
    "uat-selc-aks-azure-devops-sa-cacrt",*/
/* TODO uncomment when aks PROD will be available
    "prod-selc-aks-apiserver-url",
    "prod-selc-aks-azure-devops-sa-token",
    "prod-selc-aks-azure-devops-sa-cacrt",*/
  ]
}
