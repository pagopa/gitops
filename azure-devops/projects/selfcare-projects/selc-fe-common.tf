variable "selc-fe-common-lib" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-common-frontend"
      branch_name     = "refs/heads/main"
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
  selc-fe-common-lib-variables = {
    default_branch = var.selc-fe-common-lib.repository.branch_name
  }
  # global secrets
  selc-fe-common-lib-variables_secret = {

  }
  # code_review vars
  selc-fe-common-lib-variables_code_review = {
    danger_github_api_token = "skip"
  }
  # code_review secrets
  selc-fe-common-lib-variables_secret_code_review = {

  }
  # deploy vars
  selc-fe-common-lib-variables_deploy = {
    npm_connection = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }
  # deploy secrets
  selc-fe-common-lib-variables_secret_deploy = {

  }
}

module "selc-fe-common-lib_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v2.0.4"
  count  = var.selc-fe-common-lib.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-fe-common-lib.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-fe-common-lib-variables,
    local.selc-fe-common-lib-variables_code_review,
  )

  variables_secret = merge(
    local.selc-fe-common-lib-variables_secret,
    local.selc-fe-common-lib-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  ]
}

module "selc-fe-common-lib_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.0.4"
  count  = var.selc-fe-common-lib.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-fe-common-lib.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-fe-common-lib-variables_deploy,
    local.selc-fe-common-lib-variables,
    local.selc-fe-common-variables_deploy,
  )

  variables_secret = merge(
    local.selc-fe-common-lib-variables_secret,
    local.selc-fe-common-lib-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_npm.pagopa-npm-bot.id,
  ]
}
