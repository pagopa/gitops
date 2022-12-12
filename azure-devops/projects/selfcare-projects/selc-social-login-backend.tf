variable "hub-social-login" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "hub-social-login"
      branch_name     = "refs/heads/main"
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
  hub-social-login-variables = {
    settings_xml_rw_secure_file_name = "settings-rw.xml"
    settings_xml_ro_secure_file_name = "settings-ro.xml"
    maven_remote_repo_server_id      = "selc"
    maven_remote_repo                = "https://pkgs.dev.azure.com/pagopaspa/selfcare-projects/_packaging/selfcare/maven/v1"
    dockerfile                       = "Dockerfile"
  }
  # global secrets
  hub-social-login-variables_secret = {

  }
  # code_review vars
  hub-social-login-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.hub-social-login.repository.organization
    sonarcloud_project_key  = "${var.hub-social-login.repository.organization}_${var.hub-social-login.repository.name}"
    sonarcloud_project_name = var.hub-social-login.repository.name
  }
  # code_review secrets
  hub-social-login-variables_secret_code_review = {

  }
  # deploy vars
  hub-social-login-variables_deploy = {
    k8s_image_repository_name = replace(var.hub-social-login.repository.name, "-", "")
    deploy_namespace          = "selc"
    deployment_name           = "hub-social-login"
  }
  # deploy secrets
  hub-social-login-variables_secret_deploy = {

  }
}

module "hub-social-login_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v2.0.4"
  count  = var.hub-social-login.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.hub-social-login.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.hub-social-login-variables,
    local.hub-social-login-variables_code_review,
  )

  variables_secret = merge(
    local.hub-social-login-variables_secret,
    local.hub-social-login-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "hub-social-login_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.0.4"
  count  = var.hub-social-login.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.hub-social-login.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-be-common-variables_deploy,
    local.hub-social-login-variables,
    local.hub-social-login-variables_deploy,
  )

  variables_secret = merge(
    local.hub-social-login-variables_secret,
    local.hub-social-login-variables_secret_deploy,
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
