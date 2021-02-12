provider "azurerm" {
  features {}
}

variable "secrets" {
  default = [
    "DANGER-GITHUB-API-TOKEN",
    "pagopa-github-bot-ro-TOKEN",
    "pagopa-github-bot-rw-TOKEN",
    "pagopa-github-bot-pr-TOKEN",
    "pagopa-github-bot-EMAIL",
    "pagopa-github-bot-USERNAME",
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
