locals {
  azure_devops_org = "pagopaspa"
}

resource "azuredevops_project" "project" {
  name               = "hub-pa-projects"
  description        = "This is the DevOps project for Hub Pa projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}

resource "azuredevops_project_features" "project-features" {
  project_id = azuredevops_project.project.id
  features = {
    "boards"       = "disabled"
    "repositories" = "disabled"
    "pipelines"    = "enabled"
    "testplans"    = "disabled"
    "artifacts"    = "disabled"
  }
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
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "io-azure-devops-github-USERNAME",
    "DANGER-GITHUB-API-TOKEN",
  ]
}
