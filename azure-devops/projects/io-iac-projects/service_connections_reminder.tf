# PROD-REMINDER service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-IO-REMINDER" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-IO-REMINDER-SERVICE-CONN"
  description               = "PROD-IO-REMINDER Service connection"
  azurerm_subscription_name = "PROD-IO-REMINDER"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
}
