module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-PROD-IO-SUBSCRIPTION-ID",
    "TTDIO-DEV-IO-SUBSCRIPTION-ID",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-HUBPA-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-HUBPA-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-GCNPORTAL-SUBSCRIPTION-ID",
    "PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-SITECORP-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-SITECORP-SUBSCRIPTION-ID",
    "CERT-AZ-MANAGEMENT-MAIL-CONTACT",
  ]
}

    