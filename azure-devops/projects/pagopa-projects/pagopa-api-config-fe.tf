variable "pagopa-api-config-fe" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "pagopa-api-config-fe"
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
        project_key        = "pagopa_pagopa-api-config-fe"
        project_name       = "pagopa-api-config-fe"
      }
    }
  }
}

locals {
  # global vars
  pagopa-api-config-fe-variables = {
    cache_version_id = "v1"
    default_branch   = var.pagopa-api-config-fe.repository.branch_name
  }
  # global secrets
  pagopa-api-config-fe-variables_secret = {

  }
  # code_review vars
  pagopa-api-config-fe-variables_code_review = {
    sonarcloud_service_conn = var.pagopa-api-config-fe.pipeline.sonarcloud.service_connection
    sonarcloud_org          = var.pagopa-api-config-fe.pipeline.sonarcloud.org
    sonarcloud_project_key  = var.pagopa-api-config-fe.pipeline.sonarcloud.project_key
    sonarcloud_project_name = var.pagopa-api-config-fe.pipeline.sonarcloud.project_name
  }
  # code_review secrets
  pagopa-api-config-fe-variables_secret_code_review = {
    danger_github_api_token = "skip"
  }
  # deploy vars
  pagopa-api-config-fe-variables_deploy = {
    git_mail                        = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username                    = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection               = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    cache_version_id                = "v3"
//    healthcheck_endpoint            = "/"
//    dev_deploy_type                 = "production_slot" #or staging_slot_and_swap
//    dev_azure_subscription          = azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.service_endpoint_name
//    dev_web_app_name                = "pagopa-d-app-api-config-fe"
//    dev_web_app_resource_group_name = "pagopa-d-api-config-fe-rg"
//    uat_deploy_type                 = "production_slot" #or staging_slot_and_swap
//    uat_azure_subscription          = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.service_endpoint_name
//    uat_web_app_name                = "pagopa-u-app-api-config-fe"
//    uat_web_app_resource_group_name = "pagopa-u-api-config-fe-rg"

    blob_container_name                   = "$web"
    apim_basepath_apiconfig               = "/apiconfig/api"

//    dev = {
      apiconfig_api_host                  = "https://api.dev.platform.pagopa.it"
      endpoint_azure                      = "pagopa-d-api-config-fe-cdn-endpoint"
      profile_name_cdn_azure              = "pagopa-d-api-config-fe-cdn-profile"
      storage_account_name                = "pagopadapiconfigsa"
      resource_group_azure                = "pagopa-d-api-config-fe-rg"
      azure_subscription_storage_account  = "DEV-PAGOPA-SERVICE-CONN"
//    }
//    uat = {
//      apiconfig_api_host                  = "https://api.uat.platform.pagopa.it"
//      endpoint_azure                      = "pagopa-u-api-config-fe-cdn-endpoint"
//      profile_name_cdn_azure              = "pagopa-u-api-config-fe-cdn-profile"
//      storage_account_name                = "pagopauapiconfigsa"
//      resource_group_azure                = "pagopa-u-api-config-fe-rg"
//      azure_subscription_storage_account  = "UAT-PAGOPA-SERVICE-CONN"
//    }
//    prod = {
//      apiconfig_api_host                  = "https://api.platform.pagopa.it"
//      endpoint_azure                      = "pagopa-p-api-config-fe-cdn-endpoint"
//      profile_name_cdn_azure              = "pagopa-p-api-config-fe-cdn-profile"
//      storage_account_name                = "pagopapapiconfigsa"
//      resource_group_azure                = "pagopa-p-api-config-fe-rg"
//      azure_subscription_storage_account  = "PROD-PAGOPA-SERVICE-CONN"
//    }

  }
  # deploy secrets
  pagopa-api-config-fe-variables_secret_deploy = {

  }
}

module "pagopa-api-config-fe_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.pagopa-api-config-fe.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-api-config-fe.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pagopa-api-config-fe-variables,
    local.pagopa-api-config-fe-variables_code_review,
  )

  variables_secret = merge(
    local.pagopa-api-config-fe-variables_secret,
    local.pagopa-api-config-fe-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "pagopa-api-config-fe_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.pagopa-api-config-fe.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pagopa-api-config-fe.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  variables = merge(
    local.pagopa-api-config-fe-variables,
    local.pagopa-api-config-fe-variables_deploy,
  )

  variables_secret = merge(
    local.pagopa-api-config-fe-variables_secret,
    local.pagopa-api-config-fe-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id,
  ]
}
