module "secrets" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v2.0.4"

  resource_group = "io-p-rg-operations"
  key_vault_name = "io-p-kv-azuredevops"

  secrets = [
    "DANGER-GITHUB-API-TOKEN",
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "io-azure-devops-github-USERNAME",
    "pagopa-npm-bot-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-SELFCARE-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID",
    "SELC-DOCKER-REGISTRY-PAGOPA-USER",
    "SELC-DOCKER-REGISTRY-PAGOPA-TOKEN-RO",
    "dev-selfcare-aks-apiserver-url",
    "dev-selfcare-aks-azure-devops-sa-token",
    "dev-selfcare-aks-azure-devops-sa-cacrt",
    "uat-selfcare-aks-apiserver-url",
    "uat-selfcare-aks-azure-devops-sa-token",
    "uat-selfcare-aks-azure-devops-sa-cacrt",
    "prod-selfcare-aks-apiserver-url",
    "prod-selfcare-aks-azure-devops-sa-token",
    "prod-selfcare-aks-azure-devops-sa-cacrt",
  ]
}
