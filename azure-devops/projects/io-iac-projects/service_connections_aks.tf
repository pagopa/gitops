# PROD-SIGN service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-IO-AKS" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-IO-AKS-SERVICE-CONN"
  description               = "PROD-IO-AKS Service connection"
  azurerm_subscription_name = "PROD-IO-AKS"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
}
