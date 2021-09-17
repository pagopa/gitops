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

# TODO azure devops terraform provider does not support SonarCloud service endpoint
locals {
  azuredevops_serviceendpoint_sonarcloud_id = "NA"
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

# azure container registry dev service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-dev-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-dev-azurecr"
  resource_group            = "pagopa-d-api-rg"
  azurecr_name              = "pagopadarc"
  azurecr_subscription_name = "DEV-PAGOPA"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-DEV-PAGOPA-SUBSCRIPTION-ID"].value
}

# azure container registry dev service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-uat-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-uat-azurecr"
  resource_group            = "pagopa-u-api-rg"
  azurecr_name              = "pagopauarc"
  azurecr_subscription_name = "UAT-PAGOPA"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID"].value
}

# azure container registry dev service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-prod-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-prod-azurecr"
  resource_group            = "pagopa-p-api-rg"
  azurecr_name              = "pagopaparc"
  azurecr_subscription_name = "PROD-PAGOPA"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-PROD-PAGOPA-SUBSCRIPTION-ID"].value
}