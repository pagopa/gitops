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

# Azure service connection DEV-HUBPA
resource "azuredevops_serviceendpoint_azurerm" "DEV-HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-HUBPA-SERVICE-CONN"
  description               = "DEV-HUBPA Service connection"
  azurerm_subscription_name = "DEV-HUBPA"
  #TODO: this is going to move to the PagoPA subscription.
  azurerm_spn_tenantid    = module.secrets.values["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id = module.secrets.values["TTDIO-DEV-HUBPA-SUBSCRIPTION-ID"].value
}

# Azure service connection PROD-HUBPA
resource "azuredevops_serviceendpoint_azurerm" "PROD-HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-HUBPA-SERVICE-CONN"
  description               = "PROD-HUBPA Service connection"
  azurerm_subscription_name = "PROD-HUBPA"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-HUBPA-SUBSCRIPTION-ID"].value
}

# Azure service connection UAT-GCNPORTAL
resource "azuredevops_serviceendpoint_azurerm" "UAT-GCNPORTAL" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-GCNPORTAL-SERVICE-CONN"
  description               = "DEV-GCNPORTAL Service connection"
  azurerm_subscription_name = "DEV-GCNPORTAL"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value
}

# Production service connection PROD-GCNPORTAL
resource "azuredevops_serviceendpoint_azurerm" "PROD-GCNPORTAL" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-GCNPORTAL-SERVICE-CONN"
  description               = "PROD-GCNPORTAL Service connection"
  azurerm_subscription_name = "PROD-GCNPORTAL"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-GCNPORTAL-SUBSCRIPTION-ID"].value
}
