module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    # "TTDIO-SPN-TENANTID",
    # "TTDIO-PROD-IO-SUBSCRIPTION-ID",
    # "azure-devops-AZDO-ORG-SERVICE-URL",
    # "azure-devops-AZDO-PERSONAL-ACCESS-TOKEN",
  ]
}
