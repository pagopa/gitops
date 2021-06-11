variable "template-pipeline-package" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "template-pipeline-package"
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
  template-pipeline-package-variables = {

  }
  # global secrets
  template-pipeline-package-variables_secret = {

  }
  # code_review vars
  template-pipeline-package-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.template-pipeline-package.repository.organization
    sonarcloud_project_key  = "${var.template-pipeline-package.repository.organization}_${var.template-pipeline-package.repository.name}"
    sonarcloud_project_name = var.template-pipeline-package.repository.name
  }
  # code_review secrets
  template-pipeline-package-variables_secret_code_review = {

  }
  # deploy vars
  template-pipeline-package-variables_deploy = {

  }
  # deploy secrets
  template-pipeline-package-variables_secret_deploy = {

  }
}

module "template-pipeline-package_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review_cstar?ref=v0.0.5"
  count  = var.template-pipeline-package.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline-package.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.template-pipeline-package-variables,
    local.template-pipeline-package-variables_code_review,
  )

  variables_secret = merge(
    local.template-pipeline-package-variables_secret,
    local.template-pipeline-package-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "template-pipeline-microservice" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy_cstar?ref=v0.0.5"
  count  = var.template-pipeline-package.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline-package.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.template-pipeline-package-variables,
    local.template-pipeline-package-variables_deploy,
  )

  variables_secret = merge(
    local.template-pipeline-package-variables_secret,
    local.template-pipeline-package-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}