module "secrets" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v1.0.11"

  resource_group = local.key_vault_resource_group
  key_vault_name = local.key_vault_name

  secrets = [
    "cstar-azure-devops-github-ro-TOKEN",
    "cstar-azure-devops-github-pr-TOKEN",
    "cstar-azure-devops-github-rw-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID",
  ]
}
