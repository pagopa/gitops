variable "fa-ms-starter-parent" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "fa-ms-starter-parent"
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
  fa-ms-starter-parent-variables = {

  }
  # global secrets
  fa-ms-starter-parent-variables_secret = {

  }
  # code_review vars
  fa-ms-starter-parent-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.fa-ms-starter-parent.repository.organization
    sonarcloud_project_key  = "${var.fa-ms-starter-parent.repository.organization}_${var.fa-ms-starter-parent.repository.name}"
    sonarcloud_project_name = var.fa-ms-starter-parent.repository.name
  }
  # code_review secrets
  fa-ms-starter-parent-variables_secret_code_review = {

  }
  # deploy vars
  fa-ms-starter-parent-variables_deploy = {

  }
  # deploy secrets
  fa-ms-starter-parent-variables_secret_deploy = {

  }
}

module "fa-ms-starter-parent_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.fa-ms-starter-parent.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.fa-ms-starter-parent.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.fa-ms-starter-parent-variables,
    local.fa-ms-starter-parent-variables_code_review,
  )

  variables_secret = merge(
    local.fa-ms-starter-parent-variables_secret,
    local.fa-ms-starter-parent-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "fa-ms-starter-parent_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.fa-ms-starter-parent.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.fa-ms-starter-parent.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.fa-ms-starter-parent-variables,
    local.fa-ms-starter-parent-variables_deploy,
  )

  variables_secret = merge(
    local.fa-ms-starter-parent-variables_secret,
    local.fa-ms-starter-parent-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}