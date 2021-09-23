variable "iac" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "cstar-infrastructure"
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
  iac-variables = {
  }
  # global secrets
  iac-variables_secret = {

  }

  # code_review vars
  iac-variables_code_review = {

  }
  # code_review secrets
  iac-variables_secret_code_review = {

  }

  # deploy vars
  iac-variables_deploy = {

  }
  # deploy secrets
  iac-variables_secret_deploy = {

  }
}

module "iac_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.iac.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.iac.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.iac-variables,
    local.iac-variables_deploy,
  )

  variables_secret = merge(
    local.iac-variables_secret,
    local.iac-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.DEV-CSTAR.id,
    azuredevops_serviceendpoint_azurerm.UAT-CSTAR.id,
    azuredevops_serviceendpoint_azurerm.PROD-CSTAR.id,
  ]
}