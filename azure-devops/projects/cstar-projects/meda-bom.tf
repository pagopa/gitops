variable "meda-bom" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "meda-bom"
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
  meda-bom-variables = {

  }
  # global secrets
  meda-bom-variables_secret = {

  }
  # code_review vars
  meda-bom-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.meda-bom.repository.organization
    sonarcloud_project_key  = "${var.meda-bom.repository.organization}_${var.meda-bom.repository.name}"
    sonarcloud_project_name = var.meda-bom.repository.name
  }
  # code_review secrets
  meda-bom-variables_secret_code_review = {

  }
  # deploy vars
  meda-bom-variables_deploy = {

  }
  # deploy secrets
  meda-bom-variables_secret_deploy = {

  }
}

module "meda-bom_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.meda-bom.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.meda-bom.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.meda-bom-variables,
    local.meda-bom-variables_code_review,
  )

  variables_secret = merge(
    local.meda-bom-variables_secret,
    local.meda-bom-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "meda-bom_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.meda-bom.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.meda-bom.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.meda-bom-variables,
    local.meda-bom-variables_deploy,
  )

  variables_secret = merge(
    local.meda-bom-variables_secret,
    local.meda-bom-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}