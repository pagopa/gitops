resource "azuredevops_project" "project" {
  name               = "hub-pa-projects"
  description        = "This is the DevOps project for Hub Pa projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
