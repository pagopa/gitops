# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-ro" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-ro"
  auth_personal {
    personal_access_token = module.secrets.values["io-azure-devops-github-ro-TOKEN"].value
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
    personal_access_token = module.secrets.values["io-azure-devops-github-pr-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# TODO azure devops terraform provider does not support SonarCloud service endpoint
locals {
  azuredevops_serviceendpoint_sonarcloud_id = "1a9c808a-84ca-4d0c-8d5a-1976a1ae685f"
}

# DEV service connection
resource "azuredevops_serviceendpoint_azurerm" "DEV-PAGOPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-PAGOPA-SERVICE-CONN"
  description               = "DEV-PAGOPA Service connection"
  azurerm_subscription_name = "DEV-PAGOPA"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-DEV-PAGOPA-SUBSCRIPTION-ID"].value
}

# UAT service connection
resource "azuredevops_serviceendpoint_azurerm" "UAT-PAGOPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-PAGOPA-SERVICE-CONN"
  description               = "UAT-PAGOPA Service connection"
  azurerm_subscription_name = "UAT-PAGOPA"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID"].value
}

# DEV service connection for azure container registry 
resource "azuredevops_serviceendpoint_azurecr" "pagopa_mokcec-uat" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-azurecr-dev"
  resource_group            = "pagopa-d-aks-rg"
  azurecr_name              = "pagopadacr"
  azurecr_subscription_name = "DEV-PAGOPA"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-DEV-PAGOPA-SUBSCRIPTION-ID"].value
}
