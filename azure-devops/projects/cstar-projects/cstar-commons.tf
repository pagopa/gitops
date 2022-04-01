variable "cstar-commons" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "cstar-commons"
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
  cstar-commons-variables = {

  }
  # global secrets
  cstar-commons-variables_secret = {

  }
  # code_review vars
  cstar-commons-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.cstar-commons.repository.organization
    sonarcloud_project_key  = "${var.cstar-commons.repository.organization}_${var.cstar-commons.repository.name}"
    sonarcloud_project_name = var.cstar-commons.repository.name
  }
  # code_review secrets
  cstar-commons-variables_secret_code_review = {

  }
  # deploy vars
  cstar-commons-variables_deploy = {

  }
  # deploy secrets
  cstar-commons-variables_secret_deploy = {

  }
}

module "cstar-commons_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.cstar-commons.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.cstar-commons.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.cstar-commons-variables,
    local.cstar-commons-variables_code_review,
  )

  variables_secret = merge(
    local.cstar-commons-variables_secret,
    local.cstar-commons-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "cstar-commons_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.cstar-commons.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.cstar-commons.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.cstar-commons-variables,
    local.cstar-commons-variables_deploy,
  )

  variables_secret = merge(
    local.cstar-commons-variables_secret,
    local.cstar-commons-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}