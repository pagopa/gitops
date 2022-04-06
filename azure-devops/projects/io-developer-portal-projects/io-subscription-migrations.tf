variable "io-subscription-migrations" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-subscription-migration"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id               = "v1"
      production_resource_group_name = "io-p-selfcare-be-rg"
      production_app_name            = "io-p-subsmigrations-fn"
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-subscription-migrations-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-subscription-migrations.repository.name}.code-review"
  path       = "\\${var.io-subscription-migrations.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-subscription-migrations.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-subscription-migrations.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-subscription-migrations.repository.organization}/${var.io-subscription-migrations.repository.name}"
    branch_name           = var.io-subscription-migrations.repository.branch_name
    yml_path              = "${var.io-subscription-migrations.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-subscription-migrations.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-subscription-migrations.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "DANGER_GITHUB_API_TOKEN"
    secret_value   = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
    is_secret      = true
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-subscription-migrations-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-subscription-migrations-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-subscription-migrations-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-subscription-migrations-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-subscription-migrations-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-subscription-migrations-code-review.id
  authorized    = true
  type          = "endpoint"
}


# deploy
resource "azuredevops_build_definition" "io-subscription-migrations-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-subscription-migrations.repository.name}.deploy"
  path       = "\\${var.io-subscription-migrations.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-subscription-migrations.repository.organization}/${var.io-subscription-migrations.repository.name}"
    branch_name           = var.io-subscription-migrations.repository.branch_name
    yml_path              = "${var.io-subscription-migrations.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-subscription-migrations.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-subscription-migrations.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "GIT_EMAIL"
    value          = module.secrets.values["io-azure-devops-github-EMAIL"].value
    allow_override = false
  }

  variable {
    name           = "GIT_USERNAME"
    value          = module.secrets.values["io-azure-devops-github-USERNAME"].value
    allow_override = false
  }

  variable {
    name           = "GITHUB_CONNECTION"
    value          = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_APP_NAME"
    value          = var.io-subscription-migrations.pipeline.production_app_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_RESOURCE_GROUP_NAME"
    value          = var.io-subscription-migrations.pipeline.production_resource_group_name
    allow_override = false
  }

  variable {
    name  = "NPM_CONNECTION"
    value = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-subscription-migrations-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-subscription-migrations-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-subscription-migrations-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-subscription-migrations-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-subscription-migrations-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-subscription-migrations-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-subscription-migrations-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-subscription-migrations-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-subscription-migrations-deploy.id
  authorized    = true
  type          = "endpoint"
}
