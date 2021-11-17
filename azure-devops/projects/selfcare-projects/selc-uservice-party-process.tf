variable "selc-uservice-party-process" {
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
  selc-uservice-party-process-variables = {
    docker_base_image_name = "ghcr.io/pagopa/pdnd-interop-uservice-party-process"
    dockerfile             = "Dockerfile"
    postgres_schema        = "party" //TODO to ask if schema separated for each party application
  }
  # global secrets
  selc-uservice-party-process-variables_secret = {

  }
  # code_review vars
  selc-uservice-party-process-variables_code_review = {

  }
  # code_review secrets
  selc-uservice-party-process-variables_secret_code_review = {

  }
  # deploy vars
  selc-uservice-party-process-variables_deploy = {
    k8s_image_repository_name              = replace(replace(var.selc-uservice-party-process.repository.name, "-", ""), "selfcare", "")
    deploy_namespace                       = "selc"
    common_container_registry_name         = "ghcr.io"
    common_container_registry_service_conn = azuredevops_serviceendpoint_dockerregistry.github_docker_registry_ro.service_endpoint_name
    dev_container_registry_service_conn    = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.service_endpoint_name
    dev_kubernetes_service_conn            = azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.service_endpoint_name
    dev_container_registry_name            = "selcdacr.azurecr.io"
    dev_agent_pool                         = "selfcare-dev-linux"
    //    uat_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-uat.service_endpoint_name TODO uncomment when aks UAT will be available
    //    uat_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.selfcare-aks-uat.service_endpoint_name TODO uncomment when aks UAT will be available
    uat_container_registry_name = "selcuacr.azurecr.io"
    uat_agent_pool              = "selfcare-uat-linux"
    //    prod_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-prod.service_endpoint_name TODO uncomment when aks UAT will be available
    //    prod_kubernetes_service_conn         = azuredevops_serviceendpoint_kubernetes.selfcare-aks-prod.service_endpoint_name TODO uncomment when aks UAT will be available
    prod_container_registry_name = "selcpacr.azurecr.io"
    prod_agent_pool              = "selfcare-prod-linux"
  }
  # deploy secrets
  selc-uservice-party-process-variables_secret_deploy = {
    # docker_registry_pagopa_user     = module.secrets.values["SELC-DOCKER-REGISTRY-PAGOPA-USER"].value
    # docker_registry_pagopa_token_ro = module.secrets.values["SELC-DOCKER-REGISTRY-PAGOPA-TOKEN-RO"].value
  }
}

module "selc-uservice-party-process_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.selc-uservice-party-process.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-uservice-party-process.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-uservice-party-process-variables,
    local.selc-uservice-party-process-variables_code_review,
  )

  variables_secret = merge(
    local.selc-uservice-party-process-variables_secret,
    local.selc-uservice-party-process-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "selc-uservice-party-process_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.selc-uservice-party-process.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-uservice-party-process.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-uservice-party-process-variables,
    local.selc-uservice-party-process-variables_deploy,
    local.selc-be-uservice-common-variables_deploy
  )

  variables_secret = merge(
    local.selc-uservice-party-process-variables_secret,
    local.selc-uservice-party-process-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_dockerregistry.github_docker_registry_ro.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.id,
  ]
}
