variable "mock-ec-services" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "mock.ec-services-test"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
    }
  }
}

locals {
  # global vars
  mock-ec-services-variables = {

  }
  # global secrets
  mock-ec-services-variables_secret = {

  }

  # code_review secrets
  mock-ec-services-variables_secret_code_review = {

  }
  # deploy vars
  mock-ec-services-variables_deploy = {

  }
  # deploy secrets
  mock-ec-services-variables_secret_deploy = {

  }
}

module "mock-ec-services_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.5"
  count  = var.mock-ec-services.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.mock-ec-services.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.mock-ec-services-variables,
    local.mock-ec-services-variables_code_review,
  )

  variables_secret = merge(
    local.mock-ec-services-variables_secret,
    local.mock-ec-services-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "mock-ec-services_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.5"
  count  = var.mock-ec-services.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.mock-ec-services.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.mock-ec-services-variables,
    local.mock-ec-services-variables_deploy,
  )

  variables_secret = merge(
    local.mock-ec-services-variables_secret,
    local.mock-ec-services-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
  ]
}
