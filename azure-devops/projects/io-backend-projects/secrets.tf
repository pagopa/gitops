provider "azurerm" {
  features {}
}

variable "secrets" {
  default = [
    "DANGER-GITHUB-API-TOKEN",
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "io-azure-devops-github-USERNAME",
    "pagopa-npm-bot-TOKEN",
    "TTDIO-PROD-IO-SUBSCRIPTION-ID",
    "TTDIO-DEV-IO-SUBSCRIPTION-ID",
    "TTDIO-SPN-TENANTID",
  ]
}

data "azurerm_key_vault" "keyvault" {
  name                = "io-p-kv-azuredevops"
  resource_group_name = "io-p-rg-operations"
}

data "azurerm_key_vault_secret" "key_vault_secret" {
  for_each     = toset(var.secrets)
  name         = each.value
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
