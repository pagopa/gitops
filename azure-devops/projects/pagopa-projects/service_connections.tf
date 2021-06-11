provider "azuread" {
  tenant_id = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
}

locals {
  UAT-PAGOPA-UID  = "${local.azure_devops_org}-${azuredevops_project.project.name}-${data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID"].value}"
  service_principal_uids = [
    local.UAT-PAGOPA-UID,
  ]
}

data "azuread_service_principal" "service_principals" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-PAGOPA, azuredevops_serviceendpoint_azurerm.UAT-PAGOPA]

  for_each     = toset(local.service_principal_uids)
  display_name = each.value
}

# Azure service connection UAT-PAGOPA
resource "azuredevops_serviceendpoint_azurerm" "UAT-PAGOPA" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-PAGOPA-SERVICE-CONN"
  description               = "UAT-PAGOPA Service connection"
  azurerm_subscription_name = "UAT-PAGOPA"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID"].value
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
resource "azuredevops_serviceendpoint_azurecr" "pagopa_mokcec-uat-azurecr" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "pagopa_mokcec-uat-azurecr"
  resource_group            = "pagopa_mokcec-u-api-rg"
  azurecr_name              = "pagopa_mokcecuarc"
  azurecr_subscription_name = "UAT-mockec"
  azurecr_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurecr_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-PAGOPA-SUBSCRIPTION-ID"].value
}
