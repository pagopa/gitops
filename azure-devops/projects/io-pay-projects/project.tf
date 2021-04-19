locals {
  azure_devops_org = "pagopa-io"
}

resource "azuredevops_project" "project" {
  name               = "io-pay-projects"
  description        = "This is the DevOps project for IO PAY projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
