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
    default_branch = var.selc-fe-login.repository.branch_name
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
    dev_react_app_url_file_privacy_disclaimer  = "https://dev.selfcare.pagopa.it/assets/InformativaPrivacy.pdf"
    dev_react_app_url_file_terms_and_conditions = "https://dev.selfcare.pagopa.it/assets/terms-condition.pdf"
    uat_react_app_url_file_privacy_disclaimer  = "https://uat.selfcare.pagopa.it/assets/InformativaPrivacy.pdf"
    uat_react_app_url_file_terms_and_conditions = "https://uat.selfcare.pagopa.it/assets/terms-condition.pdf"
    prod_react_app_url_file_privacy_disclaimer  = "https://selfcare.pagopa.it/assets/InformativaPrivacy.pdf"
    prod_react_app_url_file_terms_and_conditions = "https://selfcare.pagopa.it/assets/terms-condition.pdf"
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

  pull_request_trigger_use_yaml = true

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
    local.selc-fe-common-variables_deploy,
    local.selc-fe-login-variables,
    local.selc-fe-login-variables_deploy,
  )

  variables_secret = merge(
    local.selc-fe-login-variables_secret,
    local.selc-fe-login-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-SELFCARE.id,
    azuredevops_serviceendpoint_azurerm.UAT-SELFCARE.id,
    azuredevops_serviceendpoint_azurerm.PROD-SELFCARE.id,
  ]
}
