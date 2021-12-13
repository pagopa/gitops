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
    default_branch   = var.pagopa-api-config.repository.branch_name
  }
  # global secrets
  pagopa-api-config-variables_secret = {

  }
  # code_review vars
  pagopa-api-config-variables_code_review = {
    sonarcloud_service_conn = var.pagopa-api-config.pipeline.sonarcloud.service_connection
    sonarcloud_org          = var.pagopa-api-config.pipeline.sonarcloud.org
    sonarcloud_project_key  = var.pagopa-api-config.pipeline.sonarcloud.project_key
    sonarcloud_project_name = var.pagopa-api-config.pipeline.sonarcloud.project_name
  }
  # code_review secrets
  pagopa-api-config-variables_secret_code_review = {
    danger_github_api_token = "skip"
  }
  # deploy vars
  pagopa-api-config-variables_deploy = {
    git_mail                         = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                     = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection                = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    healthcheck_endpoint             = "/api/v1/info"
    dev_deploy_type                  = "production_slot" #or staging_slot_and_swap
    dev_azure_subscription           = azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.service_endpoint_name
    dev_web_app_name                 = "pagopa-d-app-api-config"
    dev_web_app_resource_group_name  = "pagopa-d-api-config-rg"
    uat_deploy_type                  = "production_slot" #or staging_slot_and_swap
    uat_azure_subscription           = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.service_endpoint_name
    uat_web_app_name                 = "pagopa-u-app-api-config"
    uat_web_app_resource_group_name  = "pagopa-u-api-config-rg"
    prod_deploy_type                 = "production_slot" #or staging_slot_and_swap
    prod_azure_subscription          = azuredevops_serviceendpoint_azurerm.PROD-PAGOPA.service_endpoint_name
    prod_web_app_name                = "pagopa-p-app-api-config"
    prod_web_app_resource_group_name = "pagopa-p-api-config-rg"
  }
  # deploy secrets
  pagopa-api-config-variables_secret_deploy = {

  }
}

module "pagopa-api-config_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=add-trigger-to-build-definition-tls-cert"
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
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=add-trigger-to-build-definition-tls-cert"
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
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.PROD-PAGOPA.id,
  ]
}
