variable "io-functions-pushnotifications" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-functions-pushnotifications"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      production_resource_group_name = "io-p-rg-notifications"
      production_app_name            = "io-p-fn3-pushnotif"
      cache_version_id               = "v1"
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-functions-pushnotifications-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-functions-pushnotifications.repository.name}.code-review"
  path       = "\\${var.io-functions-pushnotifications.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-functions-pushnotifications.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-functions-pushnotifications.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-pushnotifications.repository.organization}/${var.io-functions-pushnotifications.repository.name}"
    branch_name           = var.io-functions-pushnotifications.repository.branch_name
    yml_path              = "${var.io-functions-pushnotifications.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }
}

resource "azuredevops_resource_authorization" "io-functions-pushnotifications-code-review-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-functions-pushnotifications-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-functions-pushnotifications-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-functions-pushnotifications-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-functions-pushnotifications.repository.name}.deploy"
  path       = "\\${var.io-functions-pushnotifications.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-pushnotifications.repository.organization}/${var.io-functions-pushnotifications.repository.name}"
    branch_name           = var.io-functions-pushnotifications.repository.branch_name
    yml_path              = "${var.io-functions-pushnotifications.repository.pipelines_path}/deploy-pipelines.yml"
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
    name  = "NPM_CONNECTION"
    value = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }

  variable {
    name  = "CACHE_VERSION_ID"
    value = var.io-functions-pushnotifications.pipeline.cache_version_id
  }

  variable {
    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
  }

  variable {
    name  = "PRODUCTION_APP_NAME"
    value = var.io-functions-pushnotifications.pipeline.production_app_name
  }

  variable {
    name  = "PRODUCTION_RESOURCE_GROUP_NAME"
    value = var.io-functions-pushnotifications.pipeline.production_resource_group_name
  }

}

resource "azuredevops_resource_authorization" "io-functions-pushnotifications-deploy-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-functions-pushnotifications-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-functions-pushnotifications-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-functions-pushnotifications-deploy-npm-auth" {
  depends_on = [azuredevops_serviceendpoint_npm.pagopa-npm-bot, azuredevops_build_definition.io-functions-pushnotifications-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_npm.pagopa-npm-bot.id
  definition_id = azuredevops_build_definition.io-functions-pushnotifications-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-functions-pushnotifications-deploy-azure-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-functions-pushnotifications-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-functions-pushnotifications-deploy.id
  authorized    = true
  type          = "endpoint"
}
