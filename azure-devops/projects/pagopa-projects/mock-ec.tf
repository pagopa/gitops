variable "mock-ec" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "mock-ec"
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
  mock-ec-variables = {

  }
  # global secrets
  mock-ec-variables_secret = {

  }
  # code_review vars
  mock-ec-variables_code_review = {

  }
  # code_review secrets
  mock-ec-variables_secret_code_review = {

  }
  # deploy vars
  mock-ec-variables_deploy = {

  }
  # deploy secrets
  mock-ec-variables_secret_deploy = {

  }
}

module "mock-ec_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.mock-ec.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.mock-ec.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.mock-ec-variables,
    local.mock-ec-variables_code_review,
  )

  variables_secret = merge(
    local.mock-ec-variables_secret,
    local.mock-ec-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

module "mock-ec_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.mock-ec.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.mock-ec.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.mock-ec-variables,
    local.mock-ec-variables_deploy,
  )

  variables_secret = merge(
    local.mock-ec-variables_secret,
    local.mock-ec-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
  ]
}
