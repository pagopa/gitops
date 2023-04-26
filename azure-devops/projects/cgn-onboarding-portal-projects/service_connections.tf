provider "azuread" {
  tenant_id = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
}

locals {
  PROD-GCNPORTAL-UID = "${local.azure_devops_org}-${azuredevops_project.project.name}-${data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-PROD-GCNPORTAL-SUBSCRIPTION-ID"].value}"
  UAT-GCNPORTAL-UID  = "${local.azure_devops_org}-${azuredevops_project.project.name}-${data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value}"
}

data "azuread_service_principal" "service_principals-PROD-GCNPORTAL" {
  depends_on   = [azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL]
  display_name = local.PROD-GCNPORTAL-UID
}

data "azuread_service_principal" "service_principals-UAT-GCNPORTAL" {
  depends_on   = [azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL]
  display_name = local.UAT-GCNPORTAL-UID
}

# Azure service connection PROD-GCNPORTAL
resource "azuredevops_serviceendpoint_azurerm" "PROD-GCNPORTAL" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-GCNPORTAL-SERVICE-CONN"
  description               = "PROD-GCNPORTAL Service connection"
  azurerm_subscription_name = "PROD-GCNPORTAL"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-PROD-GCNPORTAL-SUBSCRIPTION-ID"].value
}

# Azure service connection UAT-GCNPORTAL
resource "azuredevops_serviceendpoint_azurerm" "UAT-GCNPORTAL" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-GCNPORTAL-SERVICE-CONN"
  description               = "UAT-GCNPORTAL Service connection"
  azurerm_subscription_name = "UAT-GCNPORTAL"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value
}


# Github service connection (read-only)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-ro" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-ro"
  auth_personal {
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-ro-TOKEN"].value
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
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-rw-TOKEN"].value
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
    personal_access_token = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-pr-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# azure container registry service connection
resource "azuredevops_serviceendpoint_azurecr" "cgnonboardingportal-uat-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "cgnonboardingportal-uat-azurecr"
  resource_group            = "cgnonboardingportal-u-api-rg"
  azurecr_name              = "cgnonboardingportaluarc"
  azurecr_subscription_name = "UAT-Esercenti"
  azurecr_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value
}

# azure container registry service connection
resource "azuredevops_serviceendpoint_azurecr" "cgnonboardingportal-prod-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "cgnonboardingportal-prod-azurecr"
  resource_group            = "cgnonboardingportal-p-api-rg"
  azurecr_name              = "cgnonboardingportalparc"
  azurecr_subscription_name = "PROD-Esercenti"
  azurecr_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-PROD-GCNPORTAL-SUBSCRIPTION-ID"].value
}
