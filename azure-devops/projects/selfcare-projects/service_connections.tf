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
  azuredevops_serviceendpoint_sonarcloud_id = "f922a0a4-fb66-4cf9-bf97-d6898491a5fd" # FIXME determinare che id utilizzare
}

# DEV service connection
resource "azuredevops_serviceendpoint_azurerm" "DEV-SELFCARE" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-SELFCARE-SERVICE-CONN"
  description               = "DEV-SelfCare Service connection"
  azurerm_subscription_name = "DEV-SelfCare"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID"].value
}

# UAT service connection
resource "azuredevops_serviceendpoint_azurerm" "UAT-SELFCARE" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-SELFCARE-SERVICE-CONN"
  description               = "UAT-SelfCare Service connection"
  azurerm_subscription_name = "UAT-SelfCare"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-SELFCARE-SUBSCRIPTION-ID"].value
}

# PROD service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-SELFCARE" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-SELFCARE-SERVICE-CONN"
  description               = "PROD-SelfCare Service connection"
  azurerm_subscription_name = "PROD-SelfCare"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID"].value
}

# DEV service connection for azure container registry
resource "azuredevops_serviceendpoint_azurecr" "selfcare-azurecr-dev" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "selc-azurecr-dev"
  resource_group            = "selc-d-aks-rg"
  azurecr_name              = "selcdacr"
  azurecr_subscription_name = "DEV-SelfCare"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID"].value
}

# UAT service connection for azure container registry
resource "azuredevops_serviceendpoint_azurecr" "selfcare-azurecr-uat" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "selc-azurecr-uat"
  resource_group            = "selc-u-aks-rg"
  azurecr_name              = "selcuacr"
  azurecr_subscription_name = "UAT-SelfCare"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-UAT-SELFCARE-SUBSCRIPTION-ID"].value
}

# PROD service connection for azure container registry
resource "azuredevops_serviceendpoint_azurecr" "selfcare-azurecr-prod" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "selc-azurecr-prod"
  resource_group            = "selc-p-aks-rg"
  azurecr_name              = "selcpacr"
  azurecr_subscription_name = "PROD-SelfCare"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID"].value
}

# DEV service connection for azure kubernetes service
resource "azuredevops_serviceendpoint_kubernetes" "selfcare-aks-dev" {
  depends_on            = [azuredevops_project.project]
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "selfcare-aks-dev"
  apiserver_url         = module.secrets.values["dev-selfcare-aks-apiserver-url"].value
  authorization_type    = "ServiceAccount"
  service_account {
    # base64 values
    token   = module.secrets.values["dev-selfcare-aks-azure-devops-sa-token"].value
    ca_cert = module.secrets.values["dev-selfcare-aks-azure-devops-sa-cacrt"].value
  }
}

# UAT service connection for azure kubernetes service
resource "azuredevops_serviceendpoint_kubernetes" "selfcare-aks-uat" {
  depends_on            = [azuredevops_project.project]
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "selfcare-aks-uat"
  apiserver_url         = module.secrets.values["uat-selfcare-aks-apiserver-url"].value
  authorization_type    = "ServiceAccount"
  service_account {
    # base64 values
    token   = module.secrets.values["uat-selfcare-aks-azure-devops-sa-token"].value
    ca_cert = module.secrets.values["uat-selfcare-aks-azure-devops-sa-cacrt"].value
  }
}

# PROD service connection for azure kubernetes service
resource "azuredevops_serviceendpoint_kubernetes" "selfcare-aks-prod" {
  depends_on            = [azuredevops_project.project]
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "selfcare-aks-prod"
  apiserver_url         = module.secrets.values["prod-selfcare-aks-apiserver-url"].value
  authorization_type    = "ServiceAccount"
  service_account {
    # base64 values
    token   = module.secrets.values["prod-selfcare-aks-azure-devops-sa-token"].value
    ca_cert = module.secrets.values["prod-selfcare-aks-azure-devops-sa-cacrt"].value
  }
}