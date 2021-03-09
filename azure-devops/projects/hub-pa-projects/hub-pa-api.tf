locals {
  repository_name           = "hub-pa-api"
  repository_repo_id        = "pagopa/${local.repository_name}"
  repository_branch_name    = "main"
  repository_pipelines_path = ".devops"
  build_path                = "\\${local.repository_name}"
}

# code review
resource "azuredevops_build_definition" "hub-pa-api-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "code-review"
  path       = local.build_path

  pull_request_trigger {
    initial_branch = local.repository_branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [local.repository_branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = local.repository_repo_id
    branch_name           = local.repository_branch_name
    yml_path              = "${local.repository_pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  }
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-code-review-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.hub-pa-api-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "hub-pa-api-code-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "deploy"
  path       = local.build_path

  repository {
    repo_type             = "GitHub"
    repo_id               = local.repository_repo_id
    branch_name           = local.repository_branch_name
    yml_path              = "${local.repository_pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-deploy-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.hub-pa-api-code-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-deploy.id
  authorized    = true
  type          = "endpoint"
}
