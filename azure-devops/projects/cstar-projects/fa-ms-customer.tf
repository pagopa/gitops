variable "fa-ms-customer" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "fa-ms-customer"
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
  fa-ms-customer-variables = {
    dockerfile = "DockerfileV1"
  }
  # global secrets
  fa-ms-customer-variables_secret = {

  }
  # code_review vars
  fa-ms-customer-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.fa-ms-customer.repository.organization
    sonarcloud_project_key  = "${var.fa-ms-customer.repository.organization}_${var.fa-ms-customer.repository.name}"
    sonarcloud_project_name = var.fa-ms-customer.repository.name
  }
  # code_review secrets
  fa-ms-customer-variables_secret_code_review = {

  }
  # deploy vars
  fa-ms-customer-variables_deploy = {
    k8s_image_repository_name            = replace(var.fa-ms-customer.repository.name, "-", "")
    deploy_namespace                     = "fa"
    settings_xml_rw_secure_file_name     = "settings-rw.xml"
    settings_xml_ro_secure_file_name     = "settings-ro.xml"
    dev_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.service_endpoint_name
    dev_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.service_endpoint_name
    dev_container_registry_name          = "cstardacr.azurecr.io"
    dev_agent_pool                       = "cstar-dev-linux"
    uat_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.cstar-azurecr-uat.service_endpoint_name
    uat_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.cstar-aks-uat.service_endpoint_name
    uat_container_registry_name          = "cstaruacr.azurecr.io"
    uat_agent_pool                       = "cstar-uat-linux"
    prod_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.cstar-azurecr-prod.service_endpoint_name
    prod_kubernetes_service_conn         = azuredevops_serviceendpoint_kubernetes.cstar-aks-prod.service_endpoint_name
    prod_container_registry_name         = "cstarpacr.azurecr.io"
    prod_agent_pool                      = "cstar-prod-linux"
  }
  # deploy secrets
  fa-ms-customer-variables_secret_deploy = {

  }
}

module "fa-ms-customer_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.fa-ms-customer.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.fa-ms-customer.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.fa-ms-customer-variables,
    local.fa-ms-customer-variables_code_review,
  )

  variables_secret = merge(
    local.fa-ms-customer-variables_secret,
    local.fa-ms-customer-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "fa-ms-customer_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.fa-ms-enrollment.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.fa-ms-customer.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.fa-ms-customer-variables,
    local.fa-ms-customer-variables_deploy,
  )

  variables_secret = merge(
    local.fa-ms-customer-variables_secret,
    local.fa-ms-customer-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-CSTAR.id,
    azuredevops_serviceendpoint_azurerm.UAT-CSTAR.id,
    azuredevops_serviceendpoint_azurerm.PROD-CSTAR.id,
    azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.id,
    azuredevops_serviceendpoint_azurecr.cstar-azurecr-uat.id,
    azuredevops_serviceendpoint_kubernetes.cstar-aks-uat.id,
    azuredevops_serviceendpoint_azurecr.cstar-azurecr-prod.id,
    azuredevops_serviceendpoint_kubernetes.cstar-aks-prod.id,
  ]
}
