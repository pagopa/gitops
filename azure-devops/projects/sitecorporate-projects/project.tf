locals {
  azure_devops_org = "pagopaspa"
}

resource "azuredevops_project" "project" {
  name               = "sitecorporate-projects"
  description        = "This is the DevOps project for all Site Corporate projects"
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
