variable "pagopa-functions-checkout" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "pagopa-functions-checkout"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = "pagopa"
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
    }
  }
}

locals {
  # global vars
  pagopa-functions-checkout-variables = {
    cache_version_id = "v1"
    default_branch   = var.pagopa-functions-checkout.repository.branch_name
  }
  # global secrets
  pagopa-functions-checkout-variables_secret = {

  }
  # code_review vars
  pagopa-functions-checkout-variables_code_review = {
    danger_github_api_token = "skip"
  }
  # code_review secrets
  pagopa-functions-checkout-variables_secret_code_review = {

  }
  # deploy vars
  pagopa-functions-checkout-variables_deploy = {
    git_mail                = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username            = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection       = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    uat_azure_subscription  = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.service_endpoint_name
    prod_azure_subscription = azuredevops_serviceendpoint_azurerm.PROD-PAGOPA.service_endpoint_name
  }
  # deploy secrets
  pagopa-functions-checkout-variables_secret_deploy = {

  }
}

module "pagopa-functions-checkout_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.pagopa-functions-checkout.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-functions-checkout.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pagopa-functions-checkout-variables,
    local.pagopa-functions-checkout-variables_code_review,
  )

  variables_secret = merge(
    local.pagopa-functions-checkout-variables_secret,
    local.pagopa-functions-checkout-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  ]
}

module "pagopa-functions-checkout_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.pagopa-functions-checkout.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-functions-checkout.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.pagopa-functions-checkout-variables,
    local.pagopa-functions-checkout-variables_deploy,
  )

  variables_secret = merge(
    local.pagopa-functions-checkout-variables_secret,
    local.pagopa-functions-checkout-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.PROD-PAGOPA.id,
  ]
}
