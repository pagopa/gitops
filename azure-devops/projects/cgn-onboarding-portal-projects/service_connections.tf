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

# TODO
# azure container registry service connection
//resource "azuredevops_serviceendpoint_azurecr" "cgnonboardingportal_prod_azurecr" {
//  depends_on = [azuredevops_project.project]
//
//  project_id                = azuredevops_project.project.id
//  service_endpoint_name     = "cgnonboardingportal-prod-azurecr"
//  resource_group            = "cgnonboardingportal-p-api-rg"
//  azurecr_name              = "cgnonboardingportalparc"
//  azurecr_subscription_name = "PROD-Esercenti"
//  azurecr_spn_tenantid      = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-SPN-TENANTID"].value
//  azurecr_subscription_id   = data.azurerm_key_vault_secret.key_vault_secret["TTDIO-PROD-GCNPORTAL-SUBSCRIPTION-ID"].value
//}


# sonarqube service connection
resource "azuredevops_serviceendpoint_sonarqube" "cgnonboardingportal-sonarqube" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "cgnonboardingportal-sonarqube"
  url                   = data.azurerm_key_vault_secret.key_vault_secret["cgnportal-sonarqube-URL"].value
  token                 = data.azurerm_key_vault_secret.key_vault_secret["cgnportal-sonarqube-TOKEN"].value
  description           = "Managed by Terraform"
}

# npm service connection
resource "azuredevops_serviceendpoint_npm" "pagopa-npm-bot" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-npm-bot"
  url                   = "https://registry.npmjs.org"
  access_token          = data.azurerm_key_vault_secret.key_vault_secret["pagopa-npm-bot-TOKEN"].value
}
