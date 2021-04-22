resource "azuredevops_project" "project" {
  name               = "hub-pa-projects-new"
  description        = "This is the DevOps project for Hub Pa projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}

module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-HUBPA-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-HUBPA-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-HUBPA-SUBSCRIPTION-ID",
    "TTDIO-SPN-TENANTID",
    "TTDIO-DEV-HUBPA-SUBSCRIPTION-ID",
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "DANGER-GITHUB-API-TOKEN",
    "io-azure-devops-github-USERNAME",
    "sonarqube-TOKEN",
    "sonarqube-URL",
  ]
}
