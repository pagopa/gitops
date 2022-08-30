variable "io-pn-mock" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-pn-mock"
      branch_name     = "refs/heads/master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = false
    }
  }
}

locals {
  # global vars
  io-pn-mock-variables = {
    cache_version_id = "v1"
  }
  # global secrets
  io-pn-mock-variables_secret = {

  }
  # code_review vars
  io-pn-mock-variables_code_review = {

  }
  # code_review secrets
  io-pn-mock-variables_secret_code_review = {
    danger_github_api_token = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
  }
  # deploy vars
  io-pn-mock-variables_deploy = {

  }
  # deploy secret vars
  io-pn-mock-variables_secret_deploy = {

  }
}

#
# Code Review
#
module "io-pn-mock_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v2.6.3"
  count  = var.io-pn-mock.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-pn-mock.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  path                         = var.io-pn-mock.repository.name

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.io-pn-mock-variables,
    local.io-pn-mock-variables_code_review,
  )

  variables_secret = merge(
    local.io-pn-mock-variables_secret,
    local.io-pn-mock-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

#
# Deploy
#
module "io-pn-mock-variables_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.6.3"
  count  = var.io-pn-mock.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-pn-mock.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  path                         = var.io-pn-mock.repository.name

  variables = merge(
    local.io-pn-mock-variables,
    local.io-pn-mock-variables_deploy,
  )

  variables_secret = merge(
    local.io-pn-mock-variables_secret,
    local.io-pn-mock-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}
