variable "pagopa-checkout-io-pay" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-pay"
      branch_name     = "master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
    }
  }
}

locals {
  # global vars
  pagopa-checkout-io-pay-variables = {
    cache_version_id = "v1"
    default_branch   = var.pagopa-checkout-io-pay.repository.branch_name
  }
  # global secrets
  pagopa-checkout-io-pay-variables_secret = {

  }
  # code_review vars
  pagopa-checkout-io-pay-variables_code_review = {
    danger_github_api_token = "skip"
  }
  # code_review secrets
  pagopa-checkout-io-pay-variables_secret_code_review = {

  }
  # deploy vars
  pagopa-checkout-io-pay-variables_deploy = {
    git_mail                        = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                    = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection               = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    cache_version_id                = "v3"
    blob_container_name             = "$web"
    endpoint_azure                  = "pagopa-p-checkout-cdn-e"
    io_pay_functions_host           = "https://api.io.italia.it"
    io_pay_payment_manager_host     = "https://wisp2.pagopa.gov.it"
    my_index                        = "index.html?p=433"
    storage_account_name            = "pagopapcheckoutsa"
    profile_name_cdn_azure          = "pagopa-p-checkout-cdn-p"
    resource_group_azure            = "pagopa-p-checkout-fe-rg"
  }
  # deploy secrets
  pagopa-checkout-io-pay-variables_secret_deploy = {

  }
}

module "pagopa-checkout-io-pay_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.pagopa-checkout-io-pay.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-checkout-io-pay.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pagopa-checkout-io-pay-variables,
    local.pagopa-checkout-io-pay-variables_code_review,
  )

  variables_secret = merge(
    local.pagopa-checkout-io-pay-variables_secret,
    local.pagopa-checkout-io-pay-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "pagopa-checkout-io-pay_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.pagopa-checkout-io-pay.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-checkout-io-pay.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.pagopa-checkout-io-pay-variables,
    local.pagopa-checkout-io-pay-variables_deploy,
  )

  variables_secret = merge(
    local.pagopa-checkout-io-pay-variables_secret,
    local.pagopa-checkout-io-pay-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
  ]
}
