variable "selc-ms-product" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-ms-product"
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
  selc-ms-product-variables = {
    settings_xml_rw_secure_file_name = "settings-rw.xml"
    settings_xml_ro_secure_file_name = "settings-ro.xml"
    maven_remote_repo_server_id      = "selc"
    maven_remote_repo                = "https://pkgs.dev.azure.com/pagopaspa/selfcare-projects/_packaging/selfcare/maven/v1"
    dockerfile                       = "Dockerfile"
  }
  # global secrets
  selc-ms-product-variables_secret = {

  }
  # code_review vars
  selc-ms-product-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.selc-ms-product.repository.organization
    sonarcloud_project_key  = "${var.selc-ms-product.repository.organization}_${var.selc-ms-product.repository.name}"
    sonarcloud_project_name = var.selc-ms-product.repository.name
  }
  # code_review secrets
  selc-ms-product-variables_secret_code_review = {

  }
  # deploy vars
  selc-ms-product-variables_deploy = {
    k8s_image_repository_name           = replace(var.selc-ms-product.repository.name, "-", "")
    deploy_namespace                    = "selc"
    dev_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.service_endpoint_name
    dev_kubernetes_service_conn         = azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.service_endpoint_name
    dev_container_registry_name         = "selcdacr.azurecr.io"
    dev_agent_pool                      = "selfcare-dev-linux"
    uat_container_registry_service_conn  = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-uat.service_endpoint_name 
    uat_kubernetes_service_conn          = azuredevops_serviceendpoint_kubernetes.selfcare-aks-uat.service_endpoint_name
    uat_container_registry_name = "selcuacr.azurecr.io"
    uat_agent_pool              = "selfcare-uat-linux"
    prod_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.selfcare-azurecr-prod.service_endpoint_name
    prod_kubernetes_service_conn         = azuredevops_serviceendpoint_kubernetes.selfcare-aks-prod.service_endpoint_name
    prod_container_registry_name = "selcpacr.azurecr.io"
    prod_agent_pool              = "selfcare-prod-linux"
  }
  # deploy secrets
  selc-ms-product-variables_secret_deploy = {

  }
}

module "selc-ms-product_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.selc-ms-product.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-ms-product.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-ms-product-variables,
    local.selc-ms-product-variables_code_review,
  )

  variables_secret = merge(
    local.selc-ms-product-variables_secret,
    local.selc-ms-product-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "selc-ms-product_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.selc-ms-product.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-ms-product.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-ms-product-variables,
    local.selc-ms-product-variables_deploy,
  )

  variables_secret = merge(
    local.selc-ms-product-variables_secret,
    local.selc-ms-product-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-SELFCARE.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-dev.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev.id,
    azuredevops_serviceendpoint_azurerm.UAT-SELFCARE.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-uat.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-uat.id,
    azuredevops_serviceendpoint_azurerm.PROD-SELFCARE.id,
    azuredevops_serviceendpoint_azurecr.selfcare-azurecr-prod.id,
    azuredevops_serviceendpoint_kubernetes.selfcare-aks-prod.id,
  ]
}
