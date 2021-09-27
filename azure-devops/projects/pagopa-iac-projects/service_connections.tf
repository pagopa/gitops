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

# PROD service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-PAGOPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-PAGOPA-SERVICE-CONN"
  description               = "PROD-PAGOPA Service connection"
  azurerm_subscription_name = "PROD-PAGOPA"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-PAGOPA-SUBSCRIPTION-ID"].value
}
