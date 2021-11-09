# Azure service connection PROD-IO
resource "azuredevops_serviceendpoint_azurerm" "PROD-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "PROD-IO-SERVICE-CONN"
  description               = "PROD-IO Service connection"
  azurerm_subscription_name = "PROD-IO"

  azurerm_spn_tenantid    = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id = module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value

}

# Azure service connection DEV-IO
resource "azuredevops_serviceendpoint_azurerm" "DEV-IO" {
  depends_on = [azuredevops_project.project]

  project_id                = azuredevops_project.project.id
  service_endpoint_name     = "DEV-IO-SERVICE-CONN"
  description               = "DEV-IO Service connection"
  azurerm_subscription_name = "DEV-IO"
  azurerm_spn_tenantid      = module.secrets.values["PAGOPAIT-TENANTID"].value
  azurerm_subscription_id   = module.secrets.values["PAGOPAIT-DEV-IO-SUBSCRIPTION-ID"].value

}

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

# Github service connection (read-only) used to access to azure-pipelines template repo
resource "azuredevops_serviceendpoint_github" "pagopa" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa"
  auth_personal {
    personal_access_token = module.secrets.values["io-azure-devops-github-ro-TOKEN"].value
  }
  lifecycle {
    ignore_changes = [description, authorization]
  }
}

# npm service connection
resource "azuredevops_serviceendpoint_npm" "pagopa-npm-bot" {
  depends_on = [azuredevops_project.project]

  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa-npm-bot"
  url                   = "https://registry.npmjs.org"
  access_token          = module.secrets.values["pagopa-npm-bot-TOKEN"].value
}

module "PROD-IO-TLS-CERT-SERVICE-CONN" {
  depends_on = [azuredevops_project.project]
  source     = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_serviceendpoint_azurerm_limited?ref=v2.0.2"
  project_id = azuredevops_project.project.id

  name              = "io-p-tls-cert"
  renew_token       = local.tlscert_renew_token
  tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
  subscription_id   = module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
  subscription_name = "PROD-IO"

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group
}

data "azurerm_key_vault" "kv_common" {
  name                = format("%s-p-kv-common", local.prefix)
  resource_group_name = format("%s-p-rg-common", local.prefix)
}

resource "azurerm_key_vault_access_policy" "PROD-IO-TLS-CERT-SERVICE-CONN_kv_common" {
  key_vault_id = data.azurerm_key_vault.kv_common.id
  tenant_id    = module.secrets.values["PAGOPAIT-TENANTID"].value
  object_id    = module.PROD-IO-TLS-CERT-SERVICE-CONN.service_principal_object_id

  certificate_permissions = ["Get", "Import"]
}

data "azurerm_key_vault" "kv" {
  name                = format("%s-p-kv", local.prefix)
  resource_group_name = format("%s-p-sec-rg", local.prefix)
}

resource "azurerm_key_vault_access_policy" "PROD-IO-TLS-CERT-SERVICE-CONN_kv" {
  key_vault_id = data.azurerm_key_vault.kv.id
  tenant_id    = module.secrets.values["PAGOPAIT-TENANTID"].value
  object_id    = module.PROD-IO-TLS-CERT-SERVICE-CONN.service_principal_object_id

  certificate_permissions = ["Get", "Import"]
}
