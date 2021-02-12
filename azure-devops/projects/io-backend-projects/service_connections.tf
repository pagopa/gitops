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

# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "pagopa-github-bot-ro" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-github-bot-ro"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["pagopa-github-bot-ro-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description]
  }
}

# Github service connection (read-write)
resource "azuredevops_serviceendpoint_github" "pagopa-github-bot-rw" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-github-bot-rw"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["pagopa-github-bot-rw-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description]
  }
}
