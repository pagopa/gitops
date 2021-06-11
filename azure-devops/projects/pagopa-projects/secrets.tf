module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-PAGOPA-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID",
  ]
}
