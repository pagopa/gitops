variable "selc-uservice-party-management" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-uservice-party-management"
      branch_name     = "refs/heads/main"
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
  selc-uservice-party-management-variables = {
    docker_base_image_name = "ghcr.io/pagopa/interop-be-party-management"
    dockerfile             = "Dockerfile"
  }
  # global secrets
  selc-uservice-party-management-variables_secret = {

  }
  # code_review vars
  selc-uservice-party-management-variables_code_review = {

  }
  # code_review secrets
  selc-uservice-party-management-variables_secret_code_review = {

  }
  # deploy vars
  selc-uservice-party-management-variables_deploy = {
    k8s_image_repository_name              = replace(replace(var.selc-uservice-party-management.repository.name, "-", ""), "selfcare", "")
    deploy_namespace                       = "selc"
    common_container_registry_name         = "ghcr.io"
    common_container_registry_service_conn = azuredevops_serviceendpoint_dockerregistry.github_docker_registry_ro.service_endpoint_name
    deployment_name                        = "interop-be-party-management"
  }
  # deploy secrets
  selc-uservice-party-management-variables_secret_deploy = {

  }
}

module "selc-uservice-party-management_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v2.0.4"
  count  = var.selc-uservice-party-management.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-uservice-party-management.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-uservice-party-management-variables,
    local.selc-uservice-party-management-variables_code_review,
  )

  variables_secret = merge(
    local.selc-uservice-party-management-variables_secret,
    local.selc-uservice-party-management-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "selc-uservice-party-management_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.0.4"
  count  = var.selc-uservice-party-management.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-uservice-party-management.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-be-common-variables_deploy,
    local.selc-uservice-party-management-variables,
    local.selc-uservice-party-management-variables_deploy
  )

  variables_secret = merge(
    local.selc-uservice-party-management-variables_secret,
    local.selc-uservice-party-management-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_dockerregistry.github_docker_registry_ro.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-uat.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-uat.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-prod.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-prod.id,
  ]
}
