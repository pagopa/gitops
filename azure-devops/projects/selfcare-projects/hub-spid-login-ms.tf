variable "hub-spid-login-ms" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "hub-spid-login-ms"
      branch_name     = "master"
      pipelines_path  = ".devops/kubernetes"
      yml_prefix_name = null
    }
    pipeline = {
      enable_deploy      = true
    }
  }
}

locals {
  # global vars
  hub-spid-login-ms-variables = {
    dockerfile = "Dockerfile"
  }
  # global secrets
  hub-spid-login-ms-variables_secret = {

  }
  # code_review vars
  hub-spid-login-ms-variables_code_review = {

  }
  # code_review secrets
  hub-spid-login-ms-variables_secret_code_review = {

  }
  # deploy vars
  hub-spid-login-ms-variables_deploy = {
    k8s_image_repository_name            = replace(var.hub-spid-login-ms.repository.name, "-", "")
    deploy_namespace                     = "selc"
    dev_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.service_endpoint_name
    dev_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.service_endpoint_name
    dev_container_registry_name          = "selcdacr.azurecr.io"
    dev_agent_pool                       = "selc-dev-linux"
    dev_replicas                         = 1
/*    uat_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-uat.service_endpoint_name
    uat_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.selfcare-aks-uat.service_endpoint_name
    uat_container_registry_name          = "selcuacr.azurecr.io"
    uat_agent_pool                       = "selc-uat-linux"
    uat_replicas                         = 1
    prod_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-prod.service_endpoint_name
    prod_kubernetes_service_conn         = azuredevops_serviceendpoint_kubernetes.selfcare-aks-prod.service_endpoint_name
    prod_container_registry_name         = "selcpacr.azurecr.io"
    prod_agent_pool                      = "selc-prod-linux"
    prod_replicas                        = 2*/
  }
  # deploy secrets
  hub-spid-login-ms-variables_secret_deploy = {

  }
}

module "hub-spid-login-ms_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.hub-spid-login-ms.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.hub-spid-login-ms.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
  local.hub-spid-login-ms-variables,
  local.hub-spid-login-ms-variables_deploy,
  )

  variables_secret = merge(
  local.hub-spid-login-ms-variables_secret,
  local.hub-spid-login-ms-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-SELFCARE.id,
//    azuredevops_serviceendpoint_azurerm.UAT-SELFCARE.id, TODO uncomment when aks UAT will be available
//    azuredevops_serviceendpoint_azurerm.PROD-SELFCARE.id, TODO uncomment when aks PROD will be available
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.id,
/* TODO uncomment when aks UAT will be available
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-uat.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-uat.id,*/
/* TODO uncomment when aks PROD will be available
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-prod.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-prod.id,*/
  ]
}
