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
  azuredevops_serviceendpoint_sonarcloud_id = 1
}

# Dev service connection
resource "azuredevops_serviceendpoint_azurerm" "DEV-CSTAR" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-CSTAR-SERVICE-CONN"
  description               = "DEV-CSTAR Service connection"
  azurerm_subscription_name = "DEV-CSTAR"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID"].value
}

# # azure container registry dev service connection
# resource "azuredevops_serviceendpoint_azurecr" "cstar-azurecr-dev" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "cstar-azurecr-dev"
#   resource_group            = "cstar-d-api-rg"
#   azurecr_name              = "cstardarc"
#   azurecr_subscription_name = "DEV-CSTAR"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID"].value
# }

# # azure container registry uat service connection
# resource "azuredevops_serviceendpoint_azurecr" "cstar-azurecr-uat" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "cstar-azurecr-uat"
#   resource_group            = "cstar-u-api-rg"
#   azurecr_name              = "cstaruarc"
#   azurecr_subscription_name = "UAT-CSTAR"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID"].value
# }

# # azure container registry prod service connection
# resource "azuredevops_serviceendpoint_azurecr" "cstar-azurecr-prod" {
#   depends_on = [azuredevops_project.project]

#   project_id                = azuredevops_project.project.id
#   service_endpoint_name     = "cstar-azurecr-prod"
#   resource_group            = "cstar-p-api-rg"
#   azurecr_name              = "cstarparc"
#   azurecr_subscription_name = "PROD-CSTAR"
#   azurecr_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
#   azurecr_subscription_id   = module.secrets.values["PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID"].value
# }

# # azure kubernetes service dev service connection
# resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-dev" {
#   depends_on = [azuredevops_project.project]

#   project_id            = azuredevops_project.project.id
#   service_endpoint_name = "cstar-aks-dev"
#   apiserver_url         = "https://sample-kubernetes-cluster.hcp.westeurope.azmk8s.io" #TODO
#   authorization_type    = "AzureSubscription"

#   azure_subscription {
#     subscription_name = "DEV-CSTAR"
#     tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
#     subscription_id   = module.secrets.values["PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID"].value
#     resourcegroup_id  = "cstar-d-api-rg"
#     namespace         = "default"
#     cluster_name      = "sample-aks" #TODO
#   }
# }

# # azure kubernetes service uat service connection
# resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-uat" {
#   depends_on = [azuredevops_project.project]

#   project_id            = azuredevops_project.project.id
#   service_endpoint_name = "cstar-aks-uat"
#   apiserver_url         = "https://sample-kubernetes-cluster.hcp.westeurope.azmk8s.io" #TODO
#   authorization_type    = "AzureSubscription"

#   azure_subscription {
#     subscription_name = "UAT-CSTAR"
#     tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
#     subscription_id   = module.secrets.values["PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID"].value
#     resourcegroup_id  = "cstar-u-api-rg"
#     namespace         = "default"
#     cluster_name      = "sample-aks" #TODO
#   }
# }

# # azure kubernetes service prod service connection
# resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-prod" {
#   depends_on = [azuredevops_project.project]

#   project_id            = azuredevops_project.project.id
#   service_endpoint_name = "cstar-aks-prod"
#   apiserver_url         = "https://sample-kubernetes-cluster.hcp.westeurope.azmk8s.io" #TODO
#   authorization_type    = "AzureSubscription"

#   azure_subscription {
#     subscription_name = "PROD-CSTAR"
#     tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
#     subscription_id   = module.secrets.values["PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID"].value
#     resourcegroup_id  = "cstar-p-api-rg"
#     namespace         = "default"
#     cluster_name      = "sample-aks" #TODO
#   }
# }
