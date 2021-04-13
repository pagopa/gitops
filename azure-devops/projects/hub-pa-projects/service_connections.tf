# # Azure service connection PROD-HUBPA
# TODO PRODUCTION
# resource "azuredevops_serviceendpoint_azurerm" "PROD-HUBPA" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "PROD-HUBPA-SERVICE-CONN"
#   description               = "PROD-HUBPA Service connection"
#   azurerm_subscription_name = "PROD-HUBPA"
#   azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
#   azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-PROD-HUBPA-SUBSCRIPTION-ID"].value
# }

# Azure service connection DEV-HUBPA
resource "azuredevops_serviceendpoint_azurerm" "DEV-HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-HUBPA-SERVICE-CONN"
  description               = "DEV-HUBPA Service connection"
  azurerm_subscription_name = "DEV-HUBPA"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-DEV-HUBPA-SUBSCRIPTION-ID"].value
}

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

# azure container registry service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-azurecr"
  resource_group            = "hubpa-d-api-rg"
  azurecr_name              = "hubpadarc"
  azurecr_subscription_name = "HUBPA"
  azurecr_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
  # TODO migrate azure container registry
  azurecr_subscription_id = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-DEV-HUBPA-SUBSCRIPTION-ID"].value
}

# sonarqube service connection
resource "azuredevops_serviceendpoint_sonarqube" "pagopa-sonarqube" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-sonarqube"
  # TODO migrate sonarqube
  url         = data.azurerm_key_vault_secret.key_vault_secret["sonarqube-URL"].value
  token       = data.azurerm_key_vault_secret.key_vault_secret["sonarqube-TOKEN"].value
  description = "Managed by Terraform"
}
