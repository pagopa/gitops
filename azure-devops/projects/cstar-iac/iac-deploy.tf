variable "iac-builds" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "cstar-infrastructure"
      branch_name     = "master"
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
  iac-builds-variables = {
  }
  # global secrets
  iac-builds-variables_secret = {

  }

  # deploy vars
  iac-builds-variables_deploy = {

  }
  # deploy secrets
  iac-builds-variables_secret_deploy = {

  }
}


module "iac-builds_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.iac-builds.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.iac-builds.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.iac-builds-variables,
    local.iac-builds-variables_deploy,
  )

  variables_secret = merge(
    local.iac-builds-variables_secret,
    local.iac-builds-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}