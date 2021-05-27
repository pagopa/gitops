variable "bpd-ms-award-period" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "bpd-ms-award-period"
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
  bpd-ms-award-period-variables = {

  }
  # global secrets
  bpd-ms-award-period-variables_secret = {

  }
  # code_review vars
  bpd-ms-award-period-variables_code_review = {
    sonarcloud_service_connection = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org                = var.bpd-ms-award-period.repository.organization
    sonarcloud_project_key        = "${var.bpd-ms-award-period.repository.organization}_${var.bpd-ms-award-period.repository.name}"
    sonarcloud_project_name       = var.bpd-ms-award-period.repository.name
  }
  # code_review secrets
  bpd-ms-award-period-variables_secret_code_review = {

  }
  # deploy vars
  bpd-ms-award-period-variables_deploy = {

  }
  # deploy secrets
  bpd-ms-award-period-variables_secret_deploy = {

  }
}

module "bpd-ms-award-period_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review_cstar?ref=v0.0.5"
  count  = var.bpd-ms-award-period.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.bpd-ms-award-period.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.bpd-ms-award-period-variables,
    local.bpd-ms-award-period-variables_code_review,
  )

  variables_secret = merge(
    local.bpd-ms-award-period-variables_secret,
    local.bpd-ms-award-period-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "bpd-ms-award-period_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy_cstar?ref=v0.0.5"
  count  = var.bpd-ms-award-period.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.bpd-ms-award-period.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.bpd-ms-award-period-variables,
    local.bpd-ms-award-period-variables_deploy,
  )

  variables_secret = merge(
    local.bpd-ms-award-period-variables_secret,
    local.bpd-ms-award-period-variables_secret_deploy,
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