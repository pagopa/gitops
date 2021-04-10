# Azure service connection HUBPA
resource "azuredevops_serviceendpoint_azurerm" "HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "HUBPA-SERVICE-CONN"
  description               = "HUBPA Service connection"
  azurerm_subscription_name = "HUBPA"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["HUBPAPAGOPA-SPN-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["HUBPAPAGOPA-HUBPA-SUBSCRIPTION-ID"].value
}

# # Azure service connection DEV-IO
# resource "azuredevops_serviceendpoint_azurerm" "DEV-IO" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "DEV-IO-SERVICE-CONN"
#   description               = "DEV-IO Service connection"
#   azurerm_subscription_name = "DEV-IO"
#   azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
#   azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-DEV-IO-SUBSCRIPTION-ID"].value
# }

# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-ro" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-ro"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-ro-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# Github service connection (read-write)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-rw" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-rw"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-rw-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# Github service connection (pull request)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-pr" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-pr"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-pr-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# npm service connection
resource "azuredevops_serviceendpoint_npm" "pagopa-npm-bot" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-npm-bot"
  url                   = "https://registry.npmjs.org"
  access_token          = data.azurerm_key_vault_secret.key_vault_secret["pagopa-npm-bot-TOKEN"].value
}

# azure container registry service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-azurecr"
  resource_group            = "hubpa-d-api-rg"
  azurecr_name              = "hubpadarc"
  azurecr_subscription_name = "HUBPA"
  azurecr_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["HUBPAPAGOPA-SPN-TENANTID"].value
  azurecr_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["HUBPAPAGOPA-HUBPA-SUBSCRIPTION-ID"].value
}
