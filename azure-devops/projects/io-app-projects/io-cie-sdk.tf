variable "io-cie-sdk" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-cie-sdk"
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
  io-cie-sdk-variables = {
    cache_version_id = "v1"
  }
  # global secrets
  io-cie-sdk-variables_secret = {

  }
  # code_review vars
  io-cie-sdk-variables_code_review = {

  }
  # code_review secrets
  io-cie-sdk-variables_secret_code_review = {
    danger_github_api_token = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
  }
  # deploy vars
  io-cie-sdk-variables_deploy = {
    git_mail                       = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                   = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection              = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    npm_connection                 = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }
  # deploy secrets
  io-cie-sdk-variables_secret_deploy = {

  }
}

// Code Review
module "io-cie-sdk_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.io-cie-sdk.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-cie-sdk.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.io-cie-sdk-variables,
    local.io-cie-sdk-variables_code_review,
  )

  variables_secret = merge(
    local.io-cie-sdk-variables_secret,
    local.io-cie-sdk-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

// Deploy
module "io-cie-sdk_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.io-cie-sdk.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-cie-sdk.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.io-cie-sdk-variables,
    local.io-cie-sdk-variables_deploy,
  )

  variables_secret = merge(
    local.io-cie-sdk-variables_secret,
    local.io-cie-sdk-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
    azuredevops_serviceendpoint_npm.pagopa-npm-bot.id,
  ]
}
