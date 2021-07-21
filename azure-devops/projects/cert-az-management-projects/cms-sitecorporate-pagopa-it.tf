variable "cms-sitecorporate-pagopa-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "cert-az-management"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_cert_az = true
      path           = "sitecorporate"
      name           = "cms.sitecorporate.pagopa.it"
      # common variables to all pipelines
      variables = {
        DO_RENEW_CERT               = "true"
        PRODUCTION_AcmeDirectory    = "LE_PROD"
        PRODUCTION_CertificateNames = "cms.sitecorporate.pagopa.it"
        PRODUCTION_ResourceGroup    = "scorp-p-sec-rg"
        PRODUCTION_KeyVault         = "scorp-p-kv-common"
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
  cms-sitecorporate-pagopa-it-variables = {
    PRODUCTION_AcmeContact        = module.secrets.values["CERT-AZ-MANAGEMENT-MAIL-CONTACT"].value
    PRODUCTION_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.PROD-SITECORP.service_endpoint_name
    PRODUCTION_KeyVaultResourceId = "/subscriptions/${module.secrets.values["PAGOPAIT-PROD-SITECORP-SUBSCRIPTION-ID"].value}/resourceGroups/${var.cms-sitecorporate-pagopa-it.pipeline.variables.PRODUCTION_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.cms-sitecorporate-pagopa-it.pipeline.variables.PRODUCTION_KeyVault}"
    TEST_AcmeContact              = "NA"
    TEST_AZURE_SUBSCRIPTION       = azuredevops_serviceendpoint_azurerm.PROD-SITECORP.service_endpoint_name
    TEST_KeyVaultResourceId       = "/subscriptions/${module.secrets.values["PAGOPAIT-PROD-SITECORP-SUBSCRIPTION-ID"].value}/resourceGroups/${var.cms-sitecorporate-pagopa-it.pipeline.variables.TEST_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.cms-sitecorporate-pagopa-it.pipeline.variables.TEST_KeyVault}"
  }
  cms-sitecorporate-pagopa-it-variables_secret = {
  }
}

module "cms-sitecorporate-pagopa-it-cert_az" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_certaz?ref=v0.0.2"
  count  = var.cms-sitecorporate-pagopa-it.pipeline.enable_cert_az == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.cms-sitecorporate-pagopa-it.repository
  name                         = var.cms-sitecorporate-pagopa-it.pipeline.name
  path                         = var.cms-sitecorporate-pagopa-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.cms-sitecorporate-pagopa-it.pipeline.variables,
    local.cms-sitecorporate-pagopa-it-variables,
  )

  variables_secret = merge(
    var.cms-sitecorporate-pagopa-it.pipeline.variables_secret,
    local.cms-sitecorporate-pagopa-it-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-SITECORP.id,
  ]
}
