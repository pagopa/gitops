module "secrets" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v1.0.11"

  resource_group = local.key_vault_resource_group
  key_vault_name = local.key_vault_name

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-PAGOPA-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-PAGOPA-SUBSCRIPTION-ID",
  ]
}
