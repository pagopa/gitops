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
