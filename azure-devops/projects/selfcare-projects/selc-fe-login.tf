variable "selc-fe-login" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-login-frontend"
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
  selc-fe-login-variables = {
    cache_version_id = "v1"
    default_branch   = var.selc-fe-login.repository.branch_name
  }
  # global secrets
  selc-fe-login-variables_secret = {

  }
  # code_review vars
  selc-fe-login-variables_code_review = {
    danger_github_api_token = "skip"
  }
  # code_review secrets
  selc-fe-login-variables_secret_code_review = {

  }
  # deploy vars
  selc-fe-login-variables_deploy = {
    git_mail               = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username           = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection      = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    cache_version_id       = "v3"
    blob_container_name    = "$web"

    dev_cdn_endpoint              = "selc-d-checkout-cdn-endpoint"
    dev_cdn_profile      = "selc-d-checkout-cdn-profile"
    dev_resource_group        = "selc-d-checkout-fe-rg"
    dev_storage_account        = "selcdcheckoutsa"
    dev_react_app_url_fe_onboarding = "https://dev.selfcare.pagopa.it/onboarding"
    dev_react_app_url_fe_dashboard  = "https://dev.selfcare.pagopa.it/dashboard"
    dev_react_app_url_api_login     = "https://api.dev.selfcare.pagopa.it/spid/v1"

    uat_cdn_endpoint         = "selc-u-checkout-cdn-endpoint"
    uat_cdn_profile = "selc-u-checkout-cdn-profile"
    uat_resource_group   = "selc-u-checkout-fe-rg"
    uat_storage_account   = "selcucheckoutsa"
    uat_react_app_url_fe_onboarding = "https://uat.selfcare.pagopa.it/onboarding"
    uat_react_app_url_fe_dashboard  = "https://uat.selfcare.pagopa.it/dashboard"
    uat_react_app_url_api_login     = "https://api.uat.selfcare.pagopa.it/spid/v1"

    prod_cdn_endpoint              = "selc-p-checkout-cdn-endpoint"
    prod_cdn_profile      = "selc-p-checkout-cdn-profile"
    prod_resource_group        = "selc-p-checkout-fe-rg"
    prod_storage_account        = "selcpcheckoutsa"
    prod_react_app_url_fe_onboarding = "https://selfcare.pagopa.it/onboarding"
    prod_react_app_url_fe_dashboard  = "https://selfcare.pagopa.it/dashboard"
    prod_react_app_url_api_login     = "https://api.selfcare.pagopa.it/spid/v1"

  }
  # deploy secrets
  selc-fe-login-variables_secret_deploy = {

  }
}

module "selc-fe-login_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.selc-fe-login.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-fe-login.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.selc-fe-login-variables,
    local.selc-fe-login-variables_code_review,
  )

  variables_secret = merge(
    local.selc-fe-login-variables_secret,
    local.selc-fe-login-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  ]
}

module "selc-fe-login_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.selc-fe-login.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-fe-login.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-fe-login-variables,
    local.selc-fe-login-variables_deploy,
  )

  variables_secret = merge(
    local.selc-fe-login-variables_secret,
    local.selc-fe-login-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_servicecdn_endpointrm.DEV-SELFCARE.id,
    azuredevops_servicecdn_endpointrm.UAT-SELFCARE.id,
    azuredevops_servicecdn_endpointrm.PROD-SELFCARE.id,
  ]
}
