variable "express-azure-functions" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "azure-functions-express"
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
  express-azure-functions-variables = {
    cache_version_id = "v1"
  }
  # global secrets
  express-azure-functions-variables_secret = {

  }
  # code_review vars
  express-azure-functions-variables_code_review = {

  }
  # code_review secrets
  express-azure-functions-variables_secret_code_review = {
    danger_github_api_token = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
  }
  # deploy vars
  express-azure-functions-variables_deploy = {
    git_mail                       = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                   = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection              = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    npm_connection                 = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }
  # deploy secrets
  express-azure-functions-variables_secret_deploy = {

  }
}

module "express-azure-functions_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.express-azure-functions.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.express-azure-functions.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.express-azure-functions-variables,
    local.express-azure-functions-variables_code_review,
  )

  variables_secret = merge(
    local.express-azure-functions-variables_secret,
    local.express-azure-functions-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

module "express-azure-functions_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.express-azure-functions.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.express-azure-functions.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.express-azure-functions-variables,
    local.express-azure-functions-variables_deploy,
  )

  variables_secret = merge(
    local.express-azure-functions-variables_secret,
    local.express-azure-functions-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_npm.pagopa-npm-bot.id,
  ]
}