variable "hub-pa-api" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "hub-pa-api"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline = {
      # TODO
      production_resource_group_name = ""
      staging_resource_group_name    = ""
      production_app_name            = ""
      staging_app_name               = ""
      cache_version_id               = "v1"
    }
  }
}

# code review
resource "azuredevops_build_definition" "hub-pa-api-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.hub-pa-api.repository.name}.code-review"
  path       = "\\${var.hub-pa-api.repository.name}"

  pull_request_trigger {
    initial_branch = var.hub-pa-api.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.hub-pa-api.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.hub-pa-api.repository.organization}/${var.hub-pa-api.repository.name}"
    branch_name           = var.hub-pa-api.repository.branch_name
    yml_path              = "${var.hub-pa-api.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }

  variable {
    name  = "SONARQUBE_CONNECTION"
    value = azuredevops_serviceendpoint_sonarqube.pagopa-sonarqube.service_endpoint_name
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "hub-pa-api-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.hub-pa-api-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-review-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.hub-pa-api-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-review-sonarqube-auth" {
  depends_on = [azuredevops_serviceendpoint_sonarqube.pagopa-sonarqube, azuredevops_build_definition.hub-pa-api-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_sonarqube.pagopa-sonarqube.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "hub-pa-api-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.hub-pa-api.repository.name}.deploy"
  path       = "\\${var.hub-pa-api.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.hub-pa-api.repository.organization}/${var.hub-pa-api.repository.name}"
    branch_name           = var.hub-pa-api.repository.branch_name
    yml_path              = "${var.hub-pa-api.repository.pipelines_path}/deploy-pipelines.yml"
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
    value = var.hub-pa-api.pipeline.cache_version_id
  }

  # TODO PRODUCTION
  # variable {
  #   name  = "PRODUCTION_AZURE_SUBSCRIPTION"
  #   value = azuredevops_serviceendpoint_azurerm.PROD-HUBPA.service_endpoint_name
  # }

  variable {
    name  = "STAGING_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.DEV-HUBPA.service_endpoint_name
  }

  variable {
    name  = "PRODUCTION_APP_NAME"
    value = var.hub-pa-api.pipeline.production_app_name
  }

  variable {
    name  = "STAGING_APP_NAME"
    value = var.hub-pa-api.pipeline.staging_app_name
  }

  variable {
    name  = "PRODUCTION_RESOURCE_GROUP_NAME"
    value = var.hub-pa-api.pipeline.production_resource_group_name
  }

  variable {
    name  = "STAGING_RESOURCE_GROUP_NAME"
    value = var.hub-pa-api.pipeline.staging_resource_group_name
  }

}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "hub-pa-api-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.hub-pa-api-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.hub-pa-api-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurerm-DEV-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.DEV-HUBPA, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.DEV-HUBPA.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}

# TODO PRODUCTION
# resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurerm-PROD-HUBPA-auth" {
#   depends_on = [azuredevops_serviceendpoint_azurerm.PROD-HUBPA, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

#   project_id    = azuredevops_project.project.id
#   resource_id   = azuredevops_serviceendpoint_azurerm.PROD-HUBPA.id
#   definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
#   authorized    = true
#   type          = "endpoint"
# }

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurecr-auth" {
  depends_on = [azuredevops_serviceendpoint_azurecr.pagopa-azurecr, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.pagopa-azurecr.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}
