module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "DANGER-GITHUB-API-TOKEN",
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "io-azure-devops-github-USERNAME",
    "TTDIO-PROD-IO-SUBSCRIPTION-ID",
    "TTDIO-DEV-IO-SUBSCRIPTION-ID",
    "TTDIO-SPN-TENANTID",
  ]
}
