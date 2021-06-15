variable "gitops" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "gitops"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = "azure-devops"
    }
    pipeline = {
      enable_code_review = true
    }
  }
}

locals {
  # global vars
  gitops-variables = {

  }
  # global secrets
  gitops-variables_secret = {

  }
  # code_review vars
  gitops-variables_code_review = {

  }
  # code_review secrets
  gitops-variables_secret_code_review = {
    acr_user     = module.secrets.values["acr-common-service-principal-pull-user"].value
    acr_password = module.secrets.values["acr-common-service-principal-pull-password"].value
  }
  # deploy vars
  gitops-variables_deploy = {

  }
  # deploy secrets
  gitops-variables_secret_deploy = {

  }
}

module "gitops_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review_cstar?ref=v0.0.5"
  count  = var.gitops.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.gitops.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.gitops-variables,
    local.gitops-variables_code_review,
  )

  variables_secret = merge(
    local.gitops-variables_secret,
    local.gitops-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}
