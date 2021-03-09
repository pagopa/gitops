resource "azuredevops_project" "project" {
  name               = "hub-pa"
  description        = "This is the DevOps project for all hub pa projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
