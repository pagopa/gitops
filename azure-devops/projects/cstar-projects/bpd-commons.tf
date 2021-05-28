variable "bpd-commons" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "bpd-commons"
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
  bpd-commons-variables = {

  }
  # global secrets
  bpd-commons-variables_secret = {

  }
  # code_review vars
  bpd-commons-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.bpd-commons.repository.organization
    sonarcloud_project_key  = "${var.bpd-commons.repository.organization}_${var.bpd-commons.repository.name}"
    sonarcloud_project_name = var.bpd-commons.repository.name
  }
  # code_review secrets
  bpd-commons-variables_secret_code_review = {

  }
  # deploy vars
  bpd-commons-variables_deploy = {

  }
  # deploy secrets
  bpd-commons-variables_secret_deploy = {

  }
}

module "bpd-commons_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review_cstar?ref=v0.0.5"
  count  = var.bpd-commons.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.bpd-commons.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.bpd-commons-variables,
    local.bpd-commons-variables_code_review,
  )

  variables_secret = merge(
    local.bpd-commons-variables_secret,
    local.bpd-commons-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "bpd-commons_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy_cstar?ref=v0.0.5"
  count  = var.bpd-commons.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.bpd-commons.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.bpd-commons-variables,
    local.bpd-commons-variables_deploy,
  )

  variables_secret = merge(
    local.bpd-commons-variables_secret,
    local.bpd-commons-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}