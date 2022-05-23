variable "io-template-typescript" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-template-typescript"
      branch_name     = "master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = true
    }
  }
}

locals {
  # global vars
  io-template-typescript-variables = {
    cache_version_id = "v1"
  }
  # global secrets
  io-template-typescript-variables_secret = {

  }
  # code_review vars
  io-template-typescript-variables_code_review = {

  }
  # code_review secrets
  io-template-typescript-variables_secret_code_review = {
    danger_github_api_token = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
  }
}

module "io-template-typescript_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v0.0.3"
  count  = var.io-template-typescript.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.io-template-typescript.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.io-template-typescript-variables,
    local.io-template-typescript-variables_code_review,
  )

  variables_secret = merge(
    local.io-template-typescript-variables_secret,
    local.io-template-typescript-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}
