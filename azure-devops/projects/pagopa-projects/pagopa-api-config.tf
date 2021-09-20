variable "pagopa-api-config" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "pagopa-api-config"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
      sonarcloud = {
        # TODO azure devops terraform provider does not support SonarCloud service endpoint
        service_connection = "SONARCLOUD-SERVICE-CONN"
        org                = "pagopa"
        project_key        = "pagopa_pagopa-api-config"
        project_name       = "pagopa-api-config"
      }
    }
  }
}

locals {
  # global vars
  pagopa-api-config-variables = {
    cache_version_id = "v1"
    default_branch   = var.pagopa-mock-ec.repository.branch_name
  }
  # global secrets
  pagopa-api-config-variables_secret = {

  }
  # code_review vars
  pagopa-api-config-variables_code_review = {
    SONARCLOUD_SERVICE_CONN = var.pagopa-api-config.pipeline.sonarcloud.service_connection
    SONARCLOUD_ORG          = var.pagopa-api-config.pipeline.sonarcloud.org
    SONARCLOUD_PROJECT_KEY  = var.pagopa-api-config.pipeline.sonarcloud.project_key
    SONARCLOUD_PROJECT_NAME = var.pagopa-api-config.pipeline.sonarcloud.project_name
  }
  # code_review secrets
  pagopa-api-config-variables_secret_code_review = {
    danger_github_api_token = "skip"
  }
  # deploy vars
  pagopa-api-config-variables_deploy = {
    git_mail          = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username      = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
  }
  # deploy secrets
  pagopa-api-config-variables_secret_deploy = {

  }
}

module "pagopa-api-config_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.pagopa-api-config.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-api-config.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pagopa-api-config-variables,
    local.pagopa-api-config-variables_code_review,
  )

  variables_secret = merge(
    local.pagopa-api-config-variables_secret,
    local.pagopa-api-config-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "pagopa-api-config_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.pagopa-api-config.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-api-config.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.pagopa-api-config-variables,
    local.pagopa-api-config-variables_deploy,
  )

  variables_secret = merge(
    local.pagopa-api-config-variables_secret,
    local.pagopa-api-config-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}
