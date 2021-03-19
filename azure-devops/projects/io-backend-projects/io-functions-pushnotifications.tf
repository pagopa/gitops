locals {
  repository_name           = "io-functions-pushnotifications"
  repository_repo_id        = "pagopa/${local.repository_name}"
  repository_branch_name    = "master"
  repository_pipelines_path = ".devops"
  build_path                = "\\${local.repository_name}"
}

# code review
resource "azuredevops_build_definition" "io-functions-pushnotifications-code-review" {
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

  variable {
    name  = "DANGER_GITHUB_API_TOKEN"
    value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
  }
}

resource "azuredevops_resource_authorization" "io-functions-pushnotifications-code-review-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-functions-pushnotifications-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-functions-pushnotifications-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-functions-pushnotifications-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

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
    value = "v1"
  }

  variable {
    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
  }

  variable {
    name  = "PRODUCTION_APP_NAME"
    value = "io-p-fn3-pushnotif"
  }

  variable {
    name  = "PRODUCTION_RESOURCE_GROUP_NAME"
    value = "io-p-rg-internal"
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

resource "azuredevops_resource_authorization" "io-functions-pushnotifications-deploy-azure-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-functions-pushnotifications-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-functions-pushnotifications-deploy.id
  authorized    = true
  type          = "endpoint"
}
