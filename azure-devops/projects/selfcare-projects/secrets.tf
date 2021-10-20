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
    "dev-selfcare-aks-apiserver-url",
    "dev-selfcare-aks-azure-devops-sa-token",
    "dev-selfcare-aks-azure-devops-sa-cacrt",
    /* TODO uncomment when aks UAT will be available
    "uat-selfcare-aks-apiserver-url",
    "uat-selfcare-aks-azure-devops-sa-token",
    "uat-selfcare-aks-azure-devops-sa-cacrt",*/
    /* TODO uncomment when aks PROD will be available
    "prod-selfcare-aks-apiserver-url",
    "prod-selfcare-aks-azure-devops-sa-token",
    "prod-selfcare-aks-azure-devops-sa-cacrt",*/
  ]
}
