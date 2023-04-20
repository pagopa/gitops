provider "azuread" {
  tenant_id = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
}

locals {
  PROD-IO-UID = join("-", [local.azure_devops_org,
    azuredevops_project.project.name,
    data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
  ])
  DEV-IO-UID = join("-", [local.azure_devops_org,
    azuredevops_project.project.name,
  data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-DEV-IO-SUBSCRIPTION-ID"].value])
}

data "azuread_service_principal" "service_principals_PROD-IO" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO]

  display_name = local.PROD-IO-UID
}

data "azuread_service_principal" "service_principals_DEV-IO" {
  depends_on = [azuredevops_serviceendpoint_azurerm.DEV-IO]

  display_name = local.DEV-IO-UID
}


# Azure service connection PROD-IO
resource "azuredevops_serviceendpoint_azurerm" "PROD-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-IO-SERVICE-CONN"
  description               = "PROD-IO Service connection"
  azurerm_subscription_name = "PROD-IO"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
}

# Azure service connection DEV-IO
resource "azuredevops_serviceendpoint_azurerm" "DEV-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-IO-SERVICE-CONN"
  description               = "DEV-IO Service connection"
  azurerm_subscription_name = "DEV-IO"
  azurerm_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-DEV-IO-SUBSCRIPTION-ID"].value
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
