provider "azurerm" {
  features {}
}

variable "secrets" {
  default = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-PROD-IO-SUBSCRIPTION-ID",
    "TTDIO-DEV-IO-SUBSCRIPTION-ID",
    "PAGOPAIT-TENANTID",
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
