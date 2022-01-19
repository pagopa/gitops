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
