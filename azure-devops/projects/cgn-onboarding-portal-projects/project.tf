resource "azuredevops_project" "project" {
  name               = "cgn-portale-esercenti-projects"
  description        = "This is the DevOps project for all CGN Portale Esercenti projects"
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}
