variable "io-subscription-migrations" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-subscription-migrations"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v1"
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
