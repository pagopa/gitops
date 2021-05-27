variable "rtd-ms-arch" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "rtd-ms-arch"
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
  rtd-ms-arch-variables = {

  }
  # global secrets
  rtd-ms-arch-variables_secret = {

  }
  # code_review vars
  rtd-ms-arch-variables_code_review = {
    sonarcloud_service_connection = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org                = var.rtd-ms-arch.repository.organization
    sonarcloud_project_key        = "${var.rtd-ms-arch.repository.organization}_${var.rtd-ms-arch.repository.name}"
    sonarcloud_project_name       = var.rtd-ms-arch.repository.name
  }
  # code_review secrets
  rtd-ms-arch-variables_secret_code_review = {

  }
  # deploy vars
  rtd-ms-arch-variables_deploy = {

  }
  # deploy secrets
  rtd-ms-arch-variables_secret_deploy = {

  }
}

module "rtd-ms-arch_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review_cstar?ref=v0.0.5"
  count  = var.rtd-ms-arch.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.rtd-ms-arch.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.rtd-ms-arch-variables,
    local.rtd-ms-arch-variables_code_review,
  )

  variables_secret = merge(
    local.rtd-ms-arch-variables_secret,
    local.rtd-ms-arch-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "rtd-ms-arch_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy_cstar?ref=v0.0.5"
  count  = var.rtd-ms-arch.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.rtd-ms-arch.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.rtd-ms-arch-variables,
    local.rtd-ms-arch-variables_deploy,
  )

  variables_secret = merge(
    local.rtd-ms-arch-variables_secret,
    local.rtd-ms-arch-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}