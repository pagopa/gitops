provider "azurerm" {
  features {}
}

data "azurerm_key_vault" "keyvault" {
  name                = "io-p-kv-azuredevops"
  resource_group_name = "io-p-rg-operations"
}

data "azurerm_key_vault_secret" "DANGER-GITHUB-API-TOKEN" {
  name         = "DANGER-GITHUB-API-TOKEN"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

# read-only
data "azurerm_key_vault_secret" "pagopa-github-bot-ro-TOKEN" {
  name         = "pagopa-github-bot-ro-TOKEN"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

# read-write
data "azurerm_key_vault_secret" "pagopa-github-bot-rw-TOKEN" {
  name         = "pagopa-github-bot-rw-TOKEN"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

# pull request
data "azurerm_key_vault_secret" "pagopa-github-bot-pr-TOKEN" {
  name         = "pagopa-github-bot-pr-TOKEN"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "pagopa-github-bot-EMAIL" {
  name         = "pagopa-github-bot-EMAIL"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "pagopa-github-bot-USERNAME" {
  name         = "pagopa-github-bot-USERNAME"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "TTDIO-PROD-IO-SUBSCRIPTION-ID" {
  name         = "TTDIO-PROD-IO-SUBSCRIPTION-ID"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "TTDIO-DEV-IO-SUBSCRIPTION-ID" {
  name         = "TTDIO-DEV-IO-SUBSCRIPTION-ID"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "TTDIO-SPN-TENANTID" {
  name         = "TTDIO-SPN-TENANTID"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
