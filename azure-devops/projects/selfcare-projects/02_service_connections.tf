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

# Github service connection (read-write)
resource "azuredevops_serviceendpoint_github" "io-azure-devops-github-rw" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "io-azure-devops-github-rw"
  auth_personal {
    personal_access_token = module.secrets.values["io-azure-devops-github-rw-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# Github docker registry (read-only)
resource "azuredevops_serviceendpoint_dockerregistry" "github_docker_registry_ro" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "github-docker-registry-ro"
  docker_registry       = "https://ghcr.io"
  docker_username       = module.secrets.values["SELC-DOCKER-REGISTRY-PAGOPA-USER"].value
  docker_password       = module.secrets.values["SELC-DOCKER-REGISTRY-PAGOPA-TOKEN-RO"].value
  registry_type         = "Others"
}

# TODO azure devops terraform provider does not support SonarCloud service endpoint
locals {
  azuredevops_serviceendpoint_sonarcloud_id = "4126bdf1-3b2f-4e34-b9e7-4508d8de8ebe"
}

# DEV service connection
resource "azuredevops_serviceendpoint_azurerm" "DEV-SELFCARE" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-SELFCARE-SERVICE-CONN"
  description               = "DEV-SelfCare Service connection"
  azurerm_subscription_name = "DEV-SelfCare"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID"].value
}

# UAT service connection
resource "azuredevops_serviceendpoint_azurerm" "UAT-SELFCARE" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "UAT-SELFCARE-SERVICE-CONN"
  description               = "UAT-SelfCare Service connection"
  azurerm_subscription_name = "UAT-SelfCare"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-UAT-SELFCARE-SUBSCRIPTION-ID"].value
}

# PROD service connection
resource "azuredevops_serviceendpoint_azurerm" "PROD-SELFCARE" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-SELFCARE-SERVICE-CONN"
  description               = "PROD-SelfCare Service connection"
  azurerm_subscription_name = "PROD-SelfCare"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID"].value
}

module "DEV-SELFCARE-TLS-CERT-SERVICE-CONN" {
  depends_on = [azuredevops_project.project]
  source     = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_azurerm_limited?ref=v2.0.4"

  project_id        = azuredevops_project.project.id
  name              = "selc-d-tls-cert"
  tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
  subscription_id   = module.secrets.values["PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID"].value
  subscription_name = "DEV-SelfCare"
  #tfsec:ignore:GEN003
  renew_token = local.tlscert_renew_token

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group
}

module "UAT-SELFCARE-TLS-CERT-SERVICE-CONN" {
  depends_on = [azuredevops_project.project]
  source     = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_azurerm_limited?ref=v2.0.4"

  project_id        = azuredevops_project.project.id
  name              = "selc-u-tls-cert"
  tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
  subscription_id   = module.secrets.values["PAGOPAIT-UAT-SELFCARE-SUBSCRIPTION-ID"].value
  subscription_name = "UAT-SelfCare"
  #tfsec:ignore:GEN003
  renew_token = local.tlscert_renew_token

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group
}

module "PROD-SELFCARE-TLS-CERT-SERVICE-CONN" {
  depends_on = [azuredevops_project.project]
  source     = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_azurerm_limited?ref=v2.0.4"

  project_id        = azuredevops_project.project.id
  name              = "selc-p-tls-cert"
  tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
  subscription_id   = module.secrets.values["PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID"].value
  subscription_name = "PROD-SelfCare"
  #tfsec:ignore:GEN003
  renew_token = local.tlscert_renew_token

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group
}

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

# npm service connection
resource "azuredevops_serviceendpoint_npm" "pagopa-npm-bot" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-npm-bot"
  url                   = "https://registry.npmjs.org"
  access_token          = module.secrets.values["pagopa-npm-bot-TOKEN"].value
}
