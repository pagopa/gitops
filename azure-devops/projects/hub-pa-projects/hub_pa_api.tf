variable "hub-pa-api" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "hub-pa-api"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline = {
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
  name       = format("%s.code-review", var.hub-pa-api.repository.name)
  path       = format("\\%s", var.hub-pa-api.repository.name)

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
    repo_id               = join("/", [var.hub-pa-api.repository.organization, var.hub-pa-api.repository.name])
    branch_name           = var.hub-pa-api.repository.branch_name
    yml_path              = join("/", [var.hub-pa-api.repository.pipelines_path, "code-review-pipelines.yml"])
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }

  variable {
    name  = "SONARQUBE_CONNECTION"
    value = azuredevops_serviceendpoint_sonarqube.pagopa-sonarqube.service_endpoint_name
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "hub-pa-api-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro,
    azuredevops_build_definition.hub-pa-api-code-review,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-review-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw,
    azuredevops_build_definition.hub-pa-api-code-review,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-review-sonarqube-auth" {
  depends_on = [azuredevops_serviceendpoint_sonarqube.pagopa-sonarqube,
    azuredevops_build_definition.hub-pa-api-code-review,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_sonarqube.pagopa-sonarqube.id
  definition_id = azuredevops_build_definition.hub-pa-api-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "hub-pa-api-deploy" {
  depends_on = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-rw,
    azuredevops_project.project
  ]

  project_id = azuredevops_project.project.id
  name       = format("%s.deploy", var.hub-pa-api.repository.name)
  path       = format("\\%s", var.hub-pa-api.repository.name)

  repository {
    repo_type             = "GitHub"
    repo_id               = join("/", [var.hub-pa-api.repository.organization, var.hub-pa-api.repository.name])
    branch_name           = var.hub-pa-api.repository.branch_name
    yml_path              = join("/", [var.hub-pa-api.repository.pipelines_path, "deploy-pipelines.yml"])
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name  = "GIT_EMAIL"
    value = module.secrets.values["io-azure-devops-github-EMAIL"].value
  }

  variable {
    name  = "GIT_USERNAME"
    value = module.secrets.values["io-azure-devops-github-USERNAME"].value
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



/* TODO this service endpoint already exists. Recreate it as soon as the dev subscription will move to the PagoPa tenant.
resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurecr-auth-dev" {
  depends_on = [
    azuredevops_serviceendpoint_azurecr.pagopa-azurecr-dev,
    azuredevops_build_definition.hub-pa-api-deploy,
  time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.pagopa-azurecr-dev.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}
*/
