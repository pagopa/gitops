variable "io-functions-pay-portal" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-pay-portal"
      branch_name    = "main"
      pipelines_path = "."
    }
    pipeline = {
      production_resource_group_name = "io-p-rg-internal"
      production_app_name            = "io-p-func-iopayportal"
      cache_version_id               = "v3"
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-functions-pay-portal-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "io-functions-pay-portal.code-review"
  path       = "\\${var.io-functions-pay-portal.repository.name}\io-functions-pay-portal"

  pull_request_trigger {
    initial_branch = var.io-functions-pay-portal.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-functions-pay-portal.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-pay-portal.repository.organization}/${var.io-functions-pay-portal.repository.name}"
    branch_name           = var.io-functions-pay-portal.repository.branch_name
    yml_path              = "${var.io-functions-pay-portal.repository.pipelines_path}/io-functions-pay-portal/.devops/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-functions-pay-portal-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-functions-pay-portal-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-functions-pay-portal-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-functions-pay-portal-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-functions-pay-portal-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-functions-pay-portal-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-functions-pay-portal-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "io-functions-pay-portal.deploy"
  path       = "\\${var.io-functions-pay-portal.repository.name}\io-functions-pay-portal"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-pay-portal.repository.organization}/${var.io-functions-pay-portal.repository.name}"
    branch_name           = var.io-functions-pay-portal.repository.branch_name
    yml_path              = "${var.io-functions-pay-portal.repository.pipelines_path}/io-functions-pay-portal/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name  = "GIT_EMAIL"
    value = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-EMAIL"].value
  }

  variable {
    name  = "GIT_USERNAME"
    value = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-USERNAME"].value
  }

  variable {
    name  = "GITHUB_CONNECTION"
    value = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
  }

  variable {
    name  = "CACHE_VERSION_ID"
    value = var.io-functions-pay-portal.pipeline.cache_version_id
  }

  variable {
    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
  }

  variable {
    name  = "PRODUCTION_APP_NAME"
    value = var.io-functions-pay-portal.pipeline.production_app_name
  }

  variable {
    name  = "PRODUCTION_RESOURCE_GROUP_NAME"
    value = var.io-functions-pay-portal.pipeline.production_resource_group_name
  }

}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-functions-pay-portal-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-functions-pay-portal-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-functions-pay-portal-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-functions-pay-portal-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-functions-pay-portal-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-functions-pay-portal-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-functions-pay-portal-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-functions-pay-portal-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-functions-pay-portal-deploy.id
  authorized    = true
  type          = "endpoint"
}
