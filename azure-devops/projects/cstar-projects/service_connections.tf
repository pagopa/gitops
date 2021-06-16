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

# DEV service connection for azure kubernetes service
resource "azuredevops_serviceendpoint_kubernetes" "cstar-aks-dev" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "cstar-aks-dev"
  apiserver_url         = module.secrets.values["cstar-aks-dev-apiserver-url"].value
  authorization_type    = "Kubeconfig"

  kubeconfig {
    kube_config            = base64decode(module.secrets.values["cstar-aks-dev-kubeconfig"].value)
    accept_untrusted_certs = false
    cluster_context        = "cstar-d-aks"
  }
}
