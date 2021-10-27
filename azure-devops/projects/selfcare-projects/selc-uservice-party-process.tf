variable "selfc-uservice-party-process" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-uservice-party-process"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = false
      enable_deploy      = true
    }
  }
}

locals {
  # global vars
  selfc-uservice-party-process-variables = {

  }
  # global secrets
  selfc-uservice-party-process-variables_secret = {

  }
  # code_review vars
  selfc-uservice-party-process-variables_code_review = {

  }
  # code_review secrets
  selfc-uservice-party-process-variables_secret_code_review = {

  }
  # deploy vars
  selfc-uservice-party-process-variables_deploy = {

  }
  # deploy secrets
  selfc-uservice-party-process-variables_secret_deploy = {
    DOCKER_REGISTRY_PAGOPA_USER     = module.secrets.values["SELC-DOCKER-REGISTRY-PAGOPA-USER"].value
    DOCKER_REGISTRY_PAGOPA_TOKEN_RO = module.secrets.values["SELC-DOCKER-REGISTRY-PAGOPA-TOKEN-RO"].value
  }
}

module "selfc-uservice-party-process_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.selfc-uservice-party-process.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selfc-uservice-party-process.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selfc-uservice-party-process-variables,
    local.selfc-uservice-party-process-variables_code_review,
  )

  variables_secret = merge(
    local.selfc-uservice-party-process-variables_secret,
    local.selfc-uservice-party-process-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "selfc-uservice-party-process_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.selfc-uservice-party-process.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selfc-uservice-party-process.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selfc-uservice-party-process-variables,
    local.selfc-uservice-party-process-variables_deploy,
  )

  variables_secret = merge(
    local.selfc-uservice-party-process-variables_secret,
    local.selfc-uservice-party-process-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.id,
  ]
}
