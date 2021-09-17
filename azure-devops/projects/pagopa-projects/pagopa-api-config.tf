variable "pagopa-api-config" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "pagopa-mock-ec"
      branch_name     = "main"
      pipelines_path  = ".devops"
    }
    pipeline = {
      sonarcloud = {
        # TODO azure devops terraform provider does not support SonarCloud service endpoint
        service_connection = "SONARCLOUD-SERVICE-CONN"
        org                = "pagopa"
        project_key        = "pagopa_pagopa-api-config"
        project_name       = "pagopa-api-config"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "pagopa-api-config-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.pagopa-api-config.repository.name}.code-review"
  path       = "\\${var.pagopa-api-config.repository.name}"

  pull_request_trigger {
    initial_branch = var.pagopa-api-config.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.pagopa-api-config.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.pagopa-api-config.repository.organization}/${var.pagopa-api-config.repository.name}"
    branch_name           = var.pagopa-api-config.repository.branch_name
    yml_path              = "${var.pagopa-api-config.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "SONARCLOUD_SERVICE_CONN"
    value          = var.pagopa-api-config.pipeline.sonarcloud.service_connection
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_ORG"
    value          = var.pagopa-api-config.pipeline.sonarcloud.org
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_KEY"
    value          = var.pagopa-api-config.pipeline.sonarcloud.project_key
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_NAME"
    value          = var.pagopa-api-config.pipeline.sonarcloud.project_name
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "pagopa-api-config-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.pagopa-api-config-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.pagopa-api-config-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.pagopa-api-config-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.pagopa-api-config-code-review.id
  authorized    = true
  type          = "endpoint"
}