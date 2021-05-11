module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID",
  ]
}
