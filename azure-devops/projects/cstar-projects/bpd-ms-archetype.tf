variable "bpd-ms-archetype" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "bpd-ms-archetype"
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
  bpd-ms-archetype-variables = {

  }
  # global secrets
  bpd-ms-archetype-variables_secret = {

  }
  # code_review vars
  bpd-ms-archetype-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.bpd-ms-archetype.repository.organization
    sonarcloud_project_key  = "${var.bpd-ms-archetype.repository.organization}_${var.bpd-ms-archetype.repository.name}"
    sonarcloud_project_name = var.bpd-ms-archetype.repository.name
  }
  # code_review secrets
  bpd-ms-archetype-variables_secret_code_review = {

  }
  # deploy vars
  bpd-ms-archetype-variables_deploy = {

  }
  # deploy secrets
  bpd-ms-archetype-variables_secret_deploy = {

  }
}

module "bpd-ms-archetype_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.bpd-ms-archetype.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.bpd-ms-archetype.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.bpd-ms-archetype-variables,
    local.bpd-ms-archetype-variables_code_review,
  )

  variables_secret = merge(
    local.bpd-ms-archetype-variables_secret,
    local.bpd-ms-archetype-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "bpd-ms-archetype_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.bpd-ms-archetype.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.bpd-ms-archetype.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.bpd-ms-archetype-variables,
    local.bpd-ms-archetype-variables_deploy,
  )

  variables_secret = merge(
    local.bpd-ms-archetype-variables_secret,
    local.bpd-ms-archetype-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}