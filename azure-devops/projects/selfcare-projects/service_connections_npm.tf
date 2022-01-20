# npm service connection
resource "azuredevops_serviceendpoint_npm" "pagopa-npm-bot" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-npm-bot"
  url                   = "https://registry.npmjs.org"
  access_token          = module.secrets.values["pagopa-npm-bot-TOKEN"].value
}
