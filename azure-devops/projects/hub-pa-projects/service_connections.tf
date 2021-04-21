# # Azure service connection PROD-HUBPA
# TODO PRODUCTION
# resource "azuredevops_serviceendpoint_azurerm" "PROD-HUBPA" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "PROD-HUBPA-SERVICE-CONN"
#   description               = "PROD-HUBPA Service connection"
#   azurerm_subscription_name = "PROD-HUBPA"
#   azurerm_spn_tenantid      = module.secrets.values["TTDIO-SPN-TENANTID"].value
#   azurerm_subscription_id   = module.secrets.values["TTDIO-PROD-HUBPA-SUBSCRIPTION-ID"].value
# }


# Azure service connection DEV-HUBPA
resource "azuredevops_serviceendpoint_azurerm" "DEV-HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-HUBPA-SERVICE-CONN"
  description               = "DEV-HUBPA Service connection"
  azurerm_subscription_name = "DEV-HUBPA"
  azurerm_spn_tenantid      = module.secrets.values["TTDIO-SPN-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["TTDIO-DEV-HUBPA-SUBSCRIPTION-ID"].value
}

# Production service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-HUBPA-SERVICE-CONN"
  description               = "PROD-HUBPA Service connection"
  azurerm_subscription_name = "PROD-HUBPA"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-HUBPA-SUBSCRIPTION-ID"].value
}

# Production service connection
resource "azuredevops_serviceendpoint_azurerm" "UAT-HUBPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-HUBPA-SERVICE-CONN"
  description               = "PROD-HUBPA Service connection"
  azurerm_subscription_name = "PROD-HUBPA"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-HUBPA-SUBSCRIPTION-ID"].value
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

# azure container registry dev service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-azurecr-dev" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-azurecr"
  resource_group            = "hubpa-d-api-rg"
  azurecr_name              = "hubpadarc"
  azurecr_subscription_name = "HUBPA"
  azurecr_spn_tenantid      = module.secrets.values["TTDIO-SPN-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["TTDIO-DEV-HUBPA-SUBSCRIPTION-ID"].value
}

# azure container registry prod service connection
resource "azuredevops_serviceendpoint_azurecr" "pagopa-azurecr-prod" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa-azurecr"
  resource_group            = "hubpa-p-api-rg"
  azurecr_name              = "hubpaparc"
  azurecr_subscription_name = "PROD-HubPA"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-PROD-HUBPA-SUBSCRIPTION-ID"].value
}

# sonarqube service connection
resource "azuredevops_serviceendpoint_sonarqube" "pagopa-sonarqube" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-sonarqube"
  # TODO migrate sonarqube
  url         = module.secrets.values["sonarqube-URL"].value
  token       = module.secrets.values["sonarqube-TOKEN"].value
  description = "Managed by Terraform"
}
