# Azure service connection PROD-IO
resource "azuredevops_serviceendpoint_azurerm" "PROD-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-IO-SERVICE-CONN"
  description               = "PROD-IO Service connection"
  azurerm_subscription_name = "PROD-IO"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-PROD-IO-SUBSCRIPTION-ID"].value
}

# Azure service connection DEV-IO
resource "azuredevops_serviceendpoint_azurerm" "DEV-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-IO-SERVICE-CONN"
  description               = "DEV-IO Service connection"
  azurerm_subscription_name = "DEV-IO"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-DEV-IO-SUBSCRIPTION-ID"].value
}
