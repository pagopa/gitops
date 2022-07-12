variable "selc-fe-dashboard-users" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-dashboard-users-microfrontend"
      branch_name     = "refs/heads/main"
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
  selc-fe-dashboard-users-variables = {
    default_branch = var.selc-fe-dashboard-users.repository.branch_name
  }
  # global secrets
  selc-fe-dashboard-users-variables_secret = {

  }
  # code_review vars
  selc-fe-dashboard-users-variables_code_review = {
    danger_github_api_token = "skip"
  }
  # code_review secrets
  selc-fe-dashboard-users-variables_secret_code_review = {

  }
  # deploy vars
  selc-fe-dashboard-users-variables_deploy = {

  }
  # deploy secrets
  selc-fe-dashboard-users-variables_secret_deploy = {

  }
}

module "selc-fe-dashboard-users_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v2.0.4"
  count  = var.selc-fe-dashboard-users.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-fe-dashboard-users.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-fe-dashboard-users-variables,
    local.selc-fe-dashboard-users-variables_code_review,
  )

  variables_secret = merge(
    local.selc-fe-dashboard-users-variables_secret,
    local.selc-fe-dashboard-users-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  ]
}

module "selc-fe-dashboard-users_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.0.4"
  count  = var.selc-fe-dashboard-users.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-fe-dashboard-users.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-fe-common-variables_deploy,
    local.selc-fe-dashboard-users-variables,
    local.selc-fe-dashboard-users-variables_deploy,
  )

  variables_secret = merge(
    local.selc-fe-dashboard-users-variables_secret,
    local.selc-fe-dashboard-users-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-SELFCARE.id,
    azuredevops_serviceendpoint_azurerm.UAT-SELFCARE.id,
    azuredevops_serviceendpoint_azurerm.PROD-SELFCARE.id,
  ]
}
