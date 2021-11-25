variable "rtd-ms-transaction-filter" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "rtd-ms-transaction-filter"
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
  rtd-ms-transaction-filter-variables = {

  }
  # global secrets
  rtd-ms-transaction-filter-variables_secret = {

  }
  # code_review vars
  rtd-ms-transaction-filter-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.rtd-ms-transaction-filter.repository.organization
    sonarcloud_project_key  = "${var.rtd-ms-transaction-filter.repository.organization}_${var.rtd-ms-transaction-filter.repository.name}"
    sonarcloud_project_name = var.rtd-ms-transaction-filter.repository.name
  }
  # code_review secrets
  rtd-ms-transaction-filter-variables_secret_code_review = {

  }
  # deploy vars
  rtd-ms-transaction-filter-variables_deploy = {
    k8s_image_repository_name            = replace(var.rtd-ms-transaction-filter.repository.name, "-", "")
    deploy_namespace                     = "fa"
    settings_xml_rw_secure_file_name     = "settings-rw.xml"
    settings_xml_ro_secure_file_name     = "settings-ro.xml"
    dev_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.service_endpoint_name
    dev_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.service_endpoint_name
    dev_container_registry_name          = "cstardacr.azurecr.io"
    dev_agent_pool                       = "cstar-dev-linux"
  }
  # deploy secrets
  rtd-ms-transaction-filter-variables_secret_deploy = {

  }

}

module "rtd-ms-transaction-filter_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.rtd-ms-transaction-filter.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.rtd-ms-transaction-filter.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.rtd-ms-transaction-filter-variables,
    local.rtd-ms-transaction-filter-variables_code_review,
  )

  variables_secret = merge(
    local.rtd-ms-transaction-filter-variables_secret,
    local.rtd-ms-transaction-filter-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "rtd-ms-transaction-filter_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.rtd-ms-transaction-filter.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.rtd-ms-transaction-filter.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.rtd-ms-transaction-filter-variables,
    local.rtd-ms-transaction-filter-variables_deploy,
  )

  variables_secret = merge(
    local.rtd-ms-transaction-filter-variables_secret,
    local.rtd-ms-transaction-filter-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-CSTAR.id,
    azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.id
  ]
}