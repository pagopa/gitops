resource "azuredevops_project" "project" {
  name               = "npm-packages"
  description        = "This is the DevOps project for all public npm packages"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
