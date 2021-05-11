variable "uat-cgnonboardingportal-pagopa-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "cert-az-management"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_cert_az = false
      path           = "cgnonboardingportal"
      name           = "uat.cgnonboardingportal.pagopa.it"
      # common variables to all pipelines
      variables = {
        DO_RENEW_CERT               = "true"
        PRODUCTION_AcmeDirectory    = "LE_PROD"
        PRODUCTION_CertificateNames = "uat.cgnonboardingportal.pagopa.it"
        PRODUCTION_ResourceGroup    = "cgnonboardingportal-u-sec-rg"
        PRODUCTION_KeyVault         = "cgnonboardingportal-u-kv"
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
  uat-cgnonboardingportal-pagopa-it-variables = {
    PRODUCTION_AcmeContact        = module.secrets.values["CERT-AZ-MANAGEMENT-MAIL-CONTACT"].value
    PRODUCTION_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.service_endpoint_name
    PRODUCTION_KeyVaultResourceId = "/subscriptions/${module.secrets.values["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value}/resourceGroups/${var.uat-cgnonboardingportal-pagopa-it.pipeline.variables.PRODUCTION_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.uat-cgnonboardingportal-pagopa-it.pipeline.variables.PRODUCTION_KeyVault}"
    TEST_AcmeContact              = "NA"
    TEST_AZURE_SUBSCRIPTION       = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.service_endpoint_name
    TEST_KeyVaultResourceId       = "/subscriptions/${module.secrets.values["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value}/resourceGroups/${var.uat-cgnonboardingportal-pagopa-it.pipeline.variables.TEST_ResourceGroup}/providers/Microsoft.KeyVault/vaults/${var.uat-cgnonboardingportal-pagopa-it.pipeline.variables.TEST_KeyVault}"
  }
  uat-cgnonboardingportal-pagopa-it-variables_secret = {
  }
}

module "uat-cgnonboardingportal-pagopa-it-cert_az" {
  # source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_certaz?ref=v0.0.2"
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_certaz?ref=IOINFRA-81-fix-certaz-module"
  count  = var.uat-cgnonboardingportal-pagopa-it.pipeline.enable_cert_az == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.uat-cgnonboardingportal-pagopa-it.repository
  name                         = var.uat-cgnonboardingportal-pagopa-it.pipeline.name
  path                         = var.uat-cgnonboardingportal-pagopa-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.uat-cgnonboardingportal-pagopa-it.pipeline.variables,
    local.uat-cgnonboardingportal-pagopa-it-variables,
  )

  variables_secret = merge(
    var.uat-cgnonboardingportal-pagopa-it.pipeline.variables_secret,
    local.uat-cgnonboardingportal-pagopa-it-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.id,
  ]
}
