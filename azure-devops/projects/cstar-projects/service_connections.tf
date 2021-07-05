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
resource "azuredevops_serviceendpoint_azurerm" "DEV-CSTAR" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-CSTAR-SERVICE-CONN"
  description               = "DEV-CSTAR Service connection"
  azurerm_subscription_name = "DEV-CSTAR"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID"].value
}

# UAT service connection
resource "azuredevops_serviceendpoint_azurerm" "UAT-CSTAR" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-CSTAR-SERVICE-CONN"
  description               = "UAT-CSTAR Service connection"
  azurerm_subscription_name = "UAT-CSTAR"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID"].value
}

# PROD service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-CSTAR" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-CSTAR-SERVICE-CONN"
  description               = "PROD-CSTAR Service connection"
  azurerm_subscription_name = "PROD-CSTAR"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID"].value
}

# DEV service connection for azure container registry 
resource "azuredevops_serviceendpoint_azurecr" "cstar-azurecr-dev" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "cstar-azurecr-dev"
  resource_group            = "cstar-d-aks-rg"
  azurecr_name              = "cstardacr"
  azurecr_subscription_name = "DEV-CSTAR"
  azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = module.secrets.values["PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID"].value
}

# # UAT service connection for azure container registry 
# resource "azuredevops_serviceendpoint_azurecr" "cstar-azurecr-uat" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "cstar-azurecr-uat"
#   resource_group            = "cstar-u-aks-rg"
#   azurecr_name              = "cstaruacr"
#   azurecr_subscription_name = "UAT-CSTAR"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID"].value
# }

# # PROD service connection for azure container registry 
# resource "azuredevops_serviceendpoint_azurecr" "cstar-azurecr-prod" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "cstar-azurecr-prod"
#   resource_group            = "cstar-p-aks-rg"
#   azurecr_name              = "cstarpacr"
#   azurecr_subscription_name = "PROD-CSTAR"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID"].value
# }

# DEV service connection for azure kubernetes service
resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-dev" {
  depends_on            = [azuredevops_project.project]
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "cstar-aks-dev"
  apiserver_url         = module.secrets.values["dev-cstar-aks-apiserver-url"].value
  authorization_type    = "ServiceAccount"
  service_account {
    # base64 values
    token   = module.secrets.values["dev-cstar-aks-azure-devops-sa-token"].value
    ca_cert = module.secrets.values["dev-cstar-aks-azure-devops-sa-cacrt"].value
  }
}

# # UAT service connection for azure kubernetes service
# resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-uat" {
#   depends_on = [azuredevops_project.project]
#   project_id            = azuredevops_project.project.id
#   service_endpoint_name = "cstar-aks-uat"
#   apiserver_url         = module.secrets.values["uat-cstar-aks-apiserver-url"].value
#   authorization_type    = "ServiceAccount"
#   service_account {
#     token   = base64encode(module.secrets.values["uat-cstar-aks-azure-devops-sa-token"].value)
#     ca_cert = base64encode(module.secrets.values["uat-cstar-aks-azure-devops-sa-cacrt"].value)
#   }
# }

# # PROD service connection for azure kubernetes service
# resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-prod" {
#   depends_on = [azuredevops_project.project]
#   project_id            = azuredevops_project.project.id
#   service_endpoint_name = "cstar-aks-prod"
#   apiserver_url         = module.secrets.values["prod-cstar-aks-apiserver-url"].value
#   authorization_type    = "ServiceAccount"
#   service_account {
#     token   = base64encode(module.secrets.values["prod-cstar-aks-azure-devops-sa-token"].value)
#     ca_cert = base64encode(module.secrets.values["prod-cstar-aks-azure-devops-sa-cacrt"].value)
#   }
# }
