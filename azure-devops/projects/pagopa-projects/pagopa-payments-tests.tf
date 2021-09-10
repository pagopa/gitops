variable "pagopa-payments-tests" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "pagopa-payments-tests"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_api_tests = true
    }
  }
}

locals {
  # global vars
  pagopa-payments-tests-variables = {
    cache_version_id = "v1"
    default_branch   = var.pagopa-payments-tests.repository.branch_name
  }
  # global secrets
  pagopa-payments-tests-variables_secret = {

  }
  # api-tests vars
  pagopa-payments-tests-variables_api_tests = {
    danger_github_api_token = "skip"
  }
  # api-tests secrets
  pagopa-payments-tests-variables_secret_api_tests = {

  }
  
module "pagopa-payments-tests_api_tests" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.pagopa-payments-tests.pipeline.enable_api_tests == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-payments-tests.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pagopa-payments-tests-variables,
    local.pagopa-payments-tests-variables_api_tests,
  )

  variables_secret = merge(
    local.pagopa-payments-tests-variables_secret,
    local.pagopa-payments-tests-variables_secret_api_tests,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}