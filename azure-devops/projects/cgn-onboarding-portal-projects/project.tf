locals {
  azure_devops_org = "pagopa-io"
}

resource "azuredevops_project" "project" {
  name               = "cgn-onboarding-portal-projects"
  description        = "This is the DevOps project for all CGN Portale Esercenti projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
