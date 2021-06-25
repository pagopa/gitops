variable "cstar-docker-base" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "cstar-docker-base"
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
  cstar-docker-base-variables = {

  }
  # global secrets
  cstar-docker-base-variables_secret = {

  }
  # code_review vars
  cstar-docker-base-variables_code_review = {

  }
  # code_review secrets
  cstar-docker-base-variables_secret_code_review = {

  }
  # deploy vars
  cstar-docker-base-variables_deploy = {
    dev_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.service_endpoint_name
    dev_container_registry_name         = "cstardacr.azurecr.io"
    # uat_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.cstar-azurecr-uat.service_endpoint_name
    # uat_container_registry_name         = "cstaruacr.azurecr.io"
    # prod_container_registry_service_conn = azuredevops_serviceendpoint_azurecr.cstar-azurecr-prod.service_endpoint_name
    # prod_container_registry_name         = "cstarpacr.azurecr.io"
  }
  # deploy secrets
  cstar-docker-base-variables_secret_deploy = {

  }
}

module "cstar-docker-base_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.cstar-docker-base.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.cstar-docker-base.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.cstar-docker-base-variables,
    local.cstar-docker-base-variables_code_review,
  )

  variables_secret = merge(
    local.cstar-docker-base-variables_secret,
    local.cstar-docker-base-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}

module "cstar-docker-base_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.cstar-docker-base.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.cstar-docker-base.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.cstar-docker-base-variables,
    local.cstar-docker-base-variables_deploy,
  )

  variables_secret = merge(
    local.cstar-docker-base-variables_secret,
    local.cstar-docker-base-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-uat.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-prod.id,
  ]
}