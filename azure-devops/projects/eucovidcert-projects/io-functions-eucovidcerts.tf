variable "io-functions-eucovidcerts" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-functions-eucovidcerts"
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
  io-functions-eucovidcerts-variables = {
    cache_version_id = "v1"
  }
  # global secrets
  io-functions-eucovidcerts-variables_secret = {

  }
  # code_review vars
  io-functions-eucovidcerts-variables_code_review = {

  }
  # code_review secrets
  io-functions-eucovidcerts-variables_secret_code_review = {
    jira_username           = module.secrets.values["DANGER-JIRA-USERNAME"].value
    jira_password           = module.secrets.values["DANGER-JIRA-PASSWORD"].value
    danger_github_api_token = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
  }
  # deploy vars
  io-functions-eucovidcerts-variables_deploy = {
    git_mail                       = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                   = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection              = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    npm_connection                 = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
    production_resource_group_name = "io-p-rg-eucovidcert"
    production_app_name            = "io-p-eucovidcert-fn"
    production_azure_subscription  = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    agent_pool                     = local.agent_pool
  }
  # deploy secrets
  io-functions-eucovidcerts-variables_secret_deploy = {

  }
}

module "io-functions-eucovidcerts_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.io-functions-eucovidcerts.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-functions-eucovidcerts.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.io-functions-eucovidcerts-variables,
    local.io-functions-eucovidcerts-variables_code_review,
  )

  variables_secret = merge(
    local.io-functions-eucovidcerts-variables_secret,
    local.io-functions-eucovidcerts-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

module "io-functions-eucovidcerts_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.io-functions-eucovidcerts.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-functions-eucovidcerts.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.io-functions-eucovidcerts-variables,
    local.io-functions-eucovidcerts-variables_deploy,
  )

  variables_secret = merge(
    local.io-functions-eucovidcerts-variables_secret,
    local.io-functions-eucovidcerts-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
    azuredevops_serviceendpoint_npm.pagopa-npm-bot.id,
  ]
}