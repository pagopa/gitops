variable "template-pipeline-microservice" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "template-pipeline-microservice"
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
  template-pipeline-microservice-variables = {

  }
  # global secrets
  template-pipeline-microservice-variables_secret = {

  }
  # code_review vars
  template-pipeline-microservice-variables_code_review = {
    sonarcloud_service_connection = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org                = var.template-pipeline-microservice.repository.organization
    sonarcloud_project_key        = "${var.template-pipeline-microservice.repository.organization}_${var.template-pipeline-microservice.repository.name}"
    sonarcloud_project_name       = var.template-pipeline-microservice.repository.name
  }
  # code_review secrets
  template-pipeline-microservice-variables_secret_code_review = {

  }
  # deploy vars
  template-pipeline-microservice-variables_deploy = {

  }
  # deploy secrets
  template-pipeline-microservice-variables_secret_deploy = {

  }
}

module "template-pipeline-microservice_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review_cstar?ref=v0.0.5"
  count  = var.template-pipeline-microservice.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline-microservice.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.template-pipeline-microservice-variables,
    local.template-pipeline-microservice-variables_code_review,
  )

  variables_secret = merge(
    local.template-pipeline-microservice-variables_secret,
    local.template-pipeline-microservice-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "template-pipeline-microservice_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy_cstar?ref=v0.0.5"
  count  = var.template-pipeline-microservice.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline-microservice.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.template-pipeline-microservice-variables,
    local.template-pipeline-microservice-variables_deploy,
  )

  variables_secret = merge(
    local.template-pipeline-microservice-variables_secret,
    local.template-pipeline-microservice-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-CSTAR.id,
    azuredevops_serviceendpoint_azurerm.UAT-CSTAR.id,
    azuredevops_serviceendpoint_azurerm.PROD-CSTAR.id,
    azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.id,
  ]
}