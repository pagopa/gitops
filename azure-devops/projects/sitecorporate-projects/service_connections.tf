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

# UAT service connection
resource "azuredevops_serviceendpoint_azurerm" "UAT-SITECORP" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-SITECORP-SERVICE-CONN"
  description               = "UAT-SITECORP Service connection"
  azurerm_subscription_name = "UAT-SITECORP"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-SITECORP-SUBSCRIPTION-ID"].value
}

# PROD service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-SITECORP" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-SITECORP-SERVICE-CONN"
  description               = "PROD-SITECORP Service connection"
  azurerm_subscription_name = "PROD-SITECORP"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-SITECORP-SUBSCRIPTION-ID"].value
}

# # UAT service connection for azure container registry 
# resource "azuredevops_serviceendpoint_azurecr" "scorp-azurecr-uat" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "scorp-azurecr-uat"
#   resource_group            = "scorp-u-aks-rg"
#   azurecr_name              = "cstaruacr"
#   azurecr_subscription_name = "UAT-SITECORP"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-UAT-SITECORP-SUBSCRIPTION-ID"].value
# }

# # PROD service connection for azure container registry 
# resource "azuredevops_serviceendpoint_azurecr" "scorp-azurecr-prod" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "scorp-azurecr-prod"
#   resource_group            = "scorp-p-aks-rg"
#   azurecr_name              = "cstarpacr"
#   azurecr_subscription_name = "PROD-SITECORP"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-PROD-SITECORP-SUBSCRIPTION-ID"].value
# }
