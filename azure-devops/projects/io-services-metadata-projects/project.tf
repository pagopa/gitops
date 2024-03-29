locals {
  azure_devops_org = "pagopaspa"
}

resource "azuredevops_project" "project" {
  name               = "io-services-metadata"
  description        = "This is the DevOps project for io-services-metadata"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
