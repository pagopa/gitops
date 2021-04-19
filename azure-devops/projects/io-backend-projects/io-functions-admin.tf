variable "io-functions-admin" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-functions-admin"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id               = "v3"
      production_resource_group_name = "io-p-rg-internal"
      production_app_name            = "io-p-fn3-admin"
    }
  }
}

#
# Code Review pipeline
#

# Define code review pipeline
resource "azuredevops_build_definition" "io-functions-admin-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-functions-admin.repository.name}.code-review"
  path       = "\\${var.io-functions-admin.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-functions-admin.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-functions-admin.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-admin.repository.organization}/${var.io-functions-admin.repository.name}"
    branch_name           = var.io-functions-admin.repository.branch_name
    yml_path              = "${var.io-functions-admin.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }
}

# Allow code review pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "io-functions-admin-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.pagopa, azuredevops_build_definition.io-functions-admin-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.pagopa.id
  definition_id = azuredevops_build_definition.io-functions-admin-code-review.id
  authorized    = true
  type          = "endpoint"
}

# Allow code review pipeline to access Github pr service connection, needed to checkout code from the pull request branch
resource "azuredevops_resource_authorization" "io-functions-admin-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-functions-admin-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-functions-admin-code-review.id
  authorized    = true
  type          = "endpoint"
}

#
# Deploy pipeline
#

# Define deploy pipeline
resource "azuredevops_build_definition" "io-functions-admin-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-functions-admin.repository.name}.deploy"
  path       = "\\${var.io-functions-admin.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-admin.repository.organization}/${var.io-functions-admin.repository.name}"
    branch_name           = var.io-functions-admin.repository.branch_name
    yml_path              = "${var.io-functions-admin.repository.pipelines_path}/deploy-pipelines.yml"
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
    value = var.io-functions-admin.pipeline.cache_version_id
  }

  variable {
    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
  }

  variable {
    name  = "PRODUCTION_APP_NAME"
    value = var.io-functions-admin.pipeline.production_app_name
  }

  variable {
    name  = "PRODUCTION_RESOURCE_GROUP_NAME"
    value = var.io-functions-admin.pipeline.production_resource_group_name
  }
}

# Allow deploy pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "io-functions-admin-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.pagopa, azuredevops_build_definition.io-functions-admin-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.pagopa.id
  definition_id = azuredevops_build_definition.io-functions-admin-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Github writable service connection, needed to bump project version and publish a new relase
resource "azuredevops_resource_authorization" "io-functions-admin-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-functions-admin-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-functions-admin-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Azure PROD-IO subscription service connection, needed to interact with Azure resources
resource "azuredevops_resource_authorization" "io-functions-admin-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-functions-admin-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-functions-admin-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access NPM service connection, needed to publish sdk packages to the public registry
resource "azuredevops_resource_authorization" "io-functions-admin-deploy-npm-auth" {
  depends_on = [azuredevops_serviceendpoint_npm.pagopa-npm-bot, azuredevops_build_definition.io-functions-admin-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_npm.pagopa-npm-bot.id
  definition_id = azuredevops_build_definition.io-functions-admin-deploy.id
  authorized    = true
  type          = "endpoint"
}
