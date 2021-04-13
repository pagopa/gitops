resource "azuredevops_project" "project" {
  name               = "io-developer-portal-projects"
  description        = "This is the DevOps project for all IO backends projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
