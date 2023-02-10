module "selfcare_dev_secrets" {

  providers = {
    azurerm = azurerm.dev
  }

  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v2.18.9"

  resource_group = "selc-d-sec-rg"
  key_vault_name = "selc-d-kv"

  secrets = [
    "selc-d-aks-apiserver-url",
    "aks-azure-devops-sa-token",
    "aks-azure-devops-sa-cacrt",
  ]
}
