variable "gitops" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "gitops"
      branch_name    = "main"
      pipelines_path = ".devops"
      prefix_name    = "azure-devops"
    }
    pipeline = {
      enable_code_review = true
      # common variables to all pipelines
      variables = {
      }
      code_review_variables = {
      }
    }
  }
}

locals {
  # common variables and secrets to all pipelines
  gitops-variables = {
  }
  gitops-variables_secret = {
    # AZDO_ORG_SERVICE_URL       = module.secrets.values["azure-devops-AZDO-ORG-SERVICE-URL"].value
    # AZDO_PERSONAL_ACCESS_TOKEN = module.secrets.values["azure-devops-AZDO-PERSONAL-ACCESS-TOKEN"].value
  }
  # code review variables and secrets
  gitops-code_review_variables = {
  }
  gitops-code_review_variables_secrets = {
  }
}

module "gitops-code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=add-codereview-pipeline-module"
  count  = var.gitops.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.gitops.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.gitops.pipeline.variables,
    var.gitops.pipeline.code_review_variables,
    local.gitops-variables,
    local.gitops-code_review_variables,
  )

  variables_secret = merge(
    var.gitops.pipeline.variables_secret,
    var.gitops.pipeline.code_review_variables_secret,
    local.gitops-variables_secret,
    local.gitops-code_review_variables_secrets,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
  ]
}
