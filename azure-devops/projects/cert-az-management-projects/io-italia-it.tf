variable "io-italia-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "cert-az-management"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_cert_az = true
      path           = "io"
      name           = "io.italia.it"
      # common variables to all pipelines
      variables = {
        DO_RENEW_CERT               = "true"
        PRODUCTION_AcmeDirectory    = "LE_PROD"
        PRODUCTION_CertificateNames = "io.italia.it"
        PRODUCTION_ResourceGroup    = "io-p-rg-common"
        PRODUCTION_KeyVault         = "io-p-kv-common"
        TEST_AcmeDirectory          = "LE_STAGE"
        TEST_CertificateNames       = "NA"
        TEST_ResourceGroup          = "NA"
        TEST_KeyVault               = "NA"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  io-italia-it-variables = {
    PRODUCTION_AcmeContact        = module.secrets.values["CERT-AZ-MANAGEMENT-MAIL-CONTACT"].value
    PRODUCTION_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    PRODUCTION_KeyVaultResourceId = "/subscriptions/${module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-italia-it.pipeline.variables.PRODUCTION_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.io-italia-it.pipeline.variables.PRODUCTION_KeyVault}"
    TEST_AcmeContact              = "NA"
    TEST_AZURE_SUBSCRIPTION       = azuredevops_serviceendpoint_azurerm.DEV-IO.service_endpoint_name
    TEST_KeyVaultResourceId       = "/subscriptions/${module.secrets.values["TTDIO-DEV-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-italia-it.pipeline.variables.TEST_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.io-italia-it.pipeline.variables.TEST_KeyVault}"
  }
  io-italia-it-variables_secret = {
  }
}

module "io-italia-it-cert_az" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_certaz?ref=v0.0.2"
  count  = var.io-italia-it.pipeline.enable_cert_az == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-italia-it.repository
  name                         = var.io-italia-it.pipeline.name
  path                         = var.io-italia-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.io-italia-it.pipeline.variables,
    local.io-italia-it-variables,
  )

  variables_secret = merge(
    var.io-italia-it.pipeline.variables_secret,
    local.io-italia-it-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
    azuredevops_serviceendpoint_azurerm.DEV-IO.id,
  ]
}
