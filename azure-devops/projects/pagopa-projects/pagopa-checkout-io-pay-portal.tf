variable "pagopa-checkout-io-pay-portal" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-pay-portal"
      branch_name     = "main"
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
  pagopa-checkout-io-pay-portal-variables = {
    cache_version_id = "v1"
    default_branch   = var.pagopa-checkout-io-pay-portal.repository.branch_name
  }
  # global secrets
  pagopa-checkout-io-pay-portal-variables_secret = {

  }
  # code_review vars
  pagopa-checkout-io-pay-portal-variables_code_review = {
    danger_github_api_token = "skip"
  }
  # code_review secrets
  pagopa-checkout-io-pay-portal-variables_secret_code_review = {

  }
  # deploy vars
  pagopa-checkout-io-pay-portal-variables_deploy = {
    git_mail                        = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                    = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection               = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    cache_version_id                      = "v3"
    blob_container_name                   = "$web"
    endpoint_azure                        = "pagopa-p-checkout-cdn-e"
    io_pay_portal_api_host                = "https://api.io.italia.it"
    io_pay_portal_api_request_timeout     = "5000"
    io_pay_portal_pay_wl_host             = "https://checkout.pagopa.it"
    io_pay_portal_pay_wl_polling_attempts = "10"
    io_pay_portal_pay_wl_polling_interval = "3000"
    profile_name_cdn_azure                = "pagopa-p-checkout-cdn-p"
    resource_group_azure                  = "pagopa-p-checkout-fe-rg"
    storage_account_name                  = "pagopapcheckoutsa"
  }
  # deploy secrets
  pagopa-checkout-io-pay-portal-variables_secret_deploy = {

  }
}

module "pagopa-checkout-io-pay-portal_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.pagopa-checkout-io-pay-portal.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-checkout-io-pay-portal.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pagopa-checkout-io-pay-portal-variables,
    local.pagopa-checkout-io-pay-portal-variables_code_review,
  )

  variables_secret = merge(
    local.pagopa-checkout-io-pay-portal-variables_secret,
    local.pagopa-checkout-io-pay-portal-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  ]
}

module "pagopa-checkout-io-pay-portal_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.pagopa-checkout-io-pay-portal.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-checkout-io-pay-portal.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.pagopa-checkout-io-pay-portal-variables,
    local.pagopa-checkout-io-pay-portal-variables_deploy,
  )

  variables_secret = merge(
    local.pagopa-checkout-io-pay-portal-variables_secret,
    local.pagopa-checkout-io-pay-portal-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
  ]
}
