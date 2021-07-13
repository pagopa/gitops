module "secrets" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v1.0.11"

  resource_group = "io-p-rg-operations"
  key_vault_name = "io-p-kv-azuredevops"

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID",
    "CERT-AZ-MANAGEMENT-MAIL-CONTACT",
    "dev-cstar-aks-apiserver-url",
    "dev-cstar-aks-azure-devops-sa-token",
    "dev-cstar-aks-azure-devops-sa-cacrt",
    "uat-cstar-aks-apiserver-url",
    "uat-cstar-aks-azure-devops-sa-token",
    "uat-cstar-aks-azure-devops-sa-cacrt",
    "prod-cstar-aks-apiserver-url",
    "prod-cstar-aks-azure-devops-sa-token",
    "prod-cstar-aks-azure-devops-sa-cacrt",
  ]
}
