variable "pre-commit-terraform" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "pre-commit-terraform"
      branch_name     = "master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_deploy = true
    }
  }
}

locals {
  # global vars
  pre-commit-terraform-variables = {

  }
  # global secrets
  pre-commit-terraform-variables_secret = {

  }
  # code_review vars
  pre-commit-terraform-variables_code_review = {

  }
  # code_review secrets
  pre-commit-terraform-variables_secret_code_review = {

  }
  # deploy vars
  pre-commit-terraform-variables_deploy = {
    container_registry_service_conn = azuredevops_serviceendpoint_azurecr.common-azurecr.service_endpoint_name
    container_registry_name         = "commoncacr.azurecr.io"
  }
  # deploy secrets
  pre-commit-terraform-variables_secret_deploy = {

  }
}

module "pre-commit-terraform_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.pre-commit-terraform.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.pre-commit-terraform.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.pre-commit-terraform-variables,
    local.pre-commit-terraform-variables_deploy,
  )

  variables_secret = merge(
    local.pre-commit-terraform-variables_secret,
    local.pre-commit-terraform-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurecr.common-azurecr.id,
  ]
}
