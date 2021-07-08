variable "testtls-cstar-dev-pagopa-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "acme-tiny"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_cert_az = true
      path           = "TLS cert"
      name           = "testtls.dev.cstar.pagopa.it"
      # common variables to all pipelines
      variables = {
        DO_RENEW_CERT               = "true"
        PRODUCTION_AcmeDirectory    = "LE_PROD"
        PRODUCTION_CertificateNames = "testtls.dev.cstar.pagopa.it"
        PRODUCTION_ResourceGroup    = "cstar-d-sec-rg"
        PRODUCTION_KeyVault         = "cstar-d-kv"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  testtls-cstar-dev-pagopa-it-variables = {
    PRODUCTION_AcmeContact        = module.secrets.values["CERT-AZ-MANAGEMENT-MAIL-CONTACT"].value
    PRODUCTION_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.DEV-CSTAR.service_endpoint_name
    PRODUCTION_KeyVaultResourceId = "/subscriptions/${module.secrets.values["PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID"].value}/resourceGroups/${var.testtls-cstar-dev-pagopa-it.pipeline.variables.PRODUCTION_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.testtls-cstar-dev-pagopa-it.pipeline.variables.PRODUCTION_KeyVault}"
  }
  testtls-cstar-dev-pagopa-it-variables_secret = {
  }
}

module "testtls-cstar-dev-pagopa-it-cert_az" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_certaz?ref=v0.0.2"
  count  = var.testtls-cstar-dev-pagopa-it.pipeline.enable_cert_az == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.testtls-cstar-dev-pagopa-it.repository
  name                         = var.testtls-cstar-dev-pagopa-it.pipeline.name
  path                         = var.testtls-cstar-dev-pagopa-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id

  variables = merge(
    var.testtls-cstar-dev-pagopa-it.pipeline.variables,
    local.testtls-cstar-dev-pagopa-it-variables,
  )

  variables_secret = merge(
    var.testtls-cstar-dev-pagopa-it.pipeline.variables_secret,
    local.testtls-cstar-dev-pagopa-it-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-CSTAR.id,
  ]
}
