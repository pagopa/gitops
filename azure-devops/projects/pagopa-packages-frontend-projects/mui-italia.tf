variable "mui-italia" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "mui-italia"
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
  mui-italia-variables = {
    cache_version_id = "v1"
    default_branch   = var.mui-italia.repository.branch_name
  }
  # global secrets
  mui-italia-variables_secret = {

  }
  # code_review vars
  mui-italia-variables_code_review = {

  }
  # code_review secrets
  mui-italia-variables_secret_code_review = {
    danger_github_api_token = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
  }
  # deploy vars
  mui-italia-variables_deploy = {
    git_mail          = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username      = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    npm_connection    = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }
  # deploy secrets
  mui-italia-variables_secret_deploy = {

  }
}

module "mui-italia_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.mui-italia.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.mui-italia.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.mui-italia-variables,
    local.mui-italia-variables_code_review,
  )

  variables_secret = merge(
    local.mui-italia-variables_secret,
    local.mui-italia-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

module "mui-italia_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.mui-italia.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.mui-italia.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.mui-italia-variables,
    local.mui-italia-variables_deploy,
  )

  variables_secret = merge(
    local.mui-italia-variables_secret,
    local.mui-italia-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_npm.pagopa-npm-bot.id,
  ]
}
