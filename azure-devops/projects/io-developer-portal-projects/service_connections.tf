provider "azuread" {
  tenant_id = module.secrets.values["TTDIO-SPN-TENANTID"].value
}

locals {
  PROD-IO-UID = "${local.azure_devops_org}-${azuredevops_project.project.name}-${module.secrets.values["TTDIO-PROD-IO-SUBSCRIPTION-ID"].value}"
  DEV-IO-UID  = "${local.azure_devops_org}-${azuredevops_project.project.name}-${module.secrets.values["TTDIO-DEV-IO-SUBSCRIPTION-ID"].value}"
  service_principal_uids = [
    local.PROD-IO-UID,
    local.DEV-IO-UID,
  ]
}

data "azuread_service_principal" "service_principals" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_serviceendpoint_azurerm.DEV-IO]

  for_each     = toset(local.service_principal_uids)
  display_name = each.value
}

# Azure service connection PROD-IO
resource "azuredevops_serviceendpoint_azurerm" "PROD-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-IO-SERVICE-CONN"
  description               = "PROD-IO Service connection"
  azurerm_subscription_name = "PROD-IO"
  azurerm_spn_tenantid      = module.secrets.values["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["TTDIO-PROD-IO-SUBSCRIPTION-ID"].value
}

# Azure service connection DEV-IO
resource "azuredevops_serviceendpoint_azurerm" "DEV-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-IO-SERVICE-CONN"
  description               = "DEV-IO Service connection"
  azurerm_subscription_name = "DEV-IO"
  azurerm_spn_tenantid      = module.secrets.values["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["TTDIO-DEV-IO-SUBSCRIPTION-ID"].value
}

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

# Github service connection (read-write)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-rw" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-rw"
  auth_personal {
    personal_access_token = module.secrets.values["io-azure-devops-github-rw-TOKEN"].value
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
