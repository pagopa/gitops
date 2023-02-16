#
# Pipeline definitions for @pagopa/winston-ts package
#

variable "winston-ts" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "winston-ts" # repo name is different than actual package name
      branch_name    = "refs/heads/master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v3"
    }
  }
}

#
# Code Review pipeline
#

# Define code review pipeline
resource "azuredevops_build_definition" "winston-ts-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.winston-ts.repository.name}.code-review"
  path       = "\\${var.winston-ts.repository.name}"

  pull_request_trigger {
    initial_branch = var.winston-ts.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.winston-ts.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.winston-ts.repository.organization}/${var.winston-ts.repository.name}"
    branch_name           = var.winston-ts.repository.branch_name
    yml_path              = "${var.winston-ts.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DANGER_GITHUB_API_TOKEN"
    secret_value   = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
    is_secret      = true
    allow_override = false
  }
}

# Allow code review pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "winston-ts-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.pagopa, azuredevops_build_definition.winston-ts-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.pagopa.id
  definition_id = azuredevops_build_definition.winston-ts-code-review.id
  authorized    = true
  type          = "endpoint"
}

# Allow code review pipeline to access Github pr service connection, needed to checkout code from the pull request branch
resource "azuredevops_resource_authorization" "winston-ts-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.winston-ts-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.winston-ts-code-review.id
  authorized    = true
  type          = "endpoint"
}

#
# Deploy pipeline
#

# Define deploy pipeline
resource "azuredevops_build_definition" "winston-ts-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.winston-ts.repository.name}.deploy"
  path       = "\\${var.winston-ts.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.winston-ts.repository.organization}/${var.winston-ts.repository.name}"
    branch_name           = var.winston-ts.repository.branch_name
    yml_path              = "${var.winston-ts.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
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
    name           = "NPM_CONNECTION"
    value          = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.winston-ts.pipeline.cache_version_id
    allow_override = false
  }

}

# Allow deploy pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "winston-ts-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.pagopa, azuredevops_build_definition.winston-ts-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.pagopa.id
  definition_id = azuredevops_build_definition.winston-ts-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Github writable service connection, needed to bump project version and publish a new relase
resource "azuredevops_resource_authorization" "winston-ts-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.winston-ts-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.winston-ts-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access NPM service connection, needed to publish sdk packages to the public registry
resource "azuredevops_resource_authorization" "winston-ts-deploy-npm-auth" {
  depends_on = [azuredevops_serviceendpoint_npm.pagopa-npm-bot, azuredevops_build_definition.winston-ts-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_npm.pagopa-npm-bot.id
  definition_id = azuredevops_build_definition.winston-ts-deploy.id
  authorized    = true
  type          = "endpoint"
}
