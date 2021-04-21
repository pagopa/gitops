variable "hub-pa-fe" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "hub-pa-fe"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline = {
      # TODO
      production_storage_account_name = ""
      staging_storage_account_name    = ""
      blob_container_name             = ""
      cache_version_id                = "v1"
    }
  }
}

resource "azuredevops_build_definition" "hub-pa-fe-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.hub-pa-fe.repository.name}.code-review"
  path       = "\\${var.hub-pa-fe.repository.name}"

  pull_request_trigger {
    initial_branch = var.hub-pa-fe.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.hub-pa-fe.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = join("/", [var.hub-pa-fe.repository.organization, var.hub-pa-fe.repository.name])
    branch_name           = var.hub-pa-fe.repository.branch_name
    yml_path              = join("/", [var.hub-pa-fe.repository.pipelines_path, "/code-review-pipelines.yml"])
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
resource "azuredevops_resource_authorization" "hub-pa-fe-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro,
    azuredevops_build_definition.hub-pa-fe-code-review,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.hub-pa-fe-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-fe-code-review-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.hub-pa-fe-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.hub-pa-fe-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "hub-pa-fe-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = format("%s..deploy", var.hub-pa-fe.repository.name)
  path       = format("\\%s", var.hub-pa-fe.repository.name)

  repository {
    repo_type             = "GitHub"
    repo_id               = join("/", [var.hub-pa-fe.repository.organization, var.hub-pa-fe.repository.name])
    branch_name           = var.hub-pa-fe.repository.branch_name
    yml_path              = join("/", [var.hub-pa-fe.repository.pipelines_path], ["deploy-pipelines.yml"])
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  # TODO vars
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
    value = var.hub-pa-fe.pipeline.cache_version_id
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
    name  = "PRODUCTION_STORAGE_ACCOUNT_NAME"
    value = var.hub-pa-fe.pipeline.production_storage_account_name
  }

  variable {
    name  = "STAGING_STORAGE_ACCOUNT_NAME"
    value = var.hub-pa-fe.pipeline.staging_storage_account_name
  }

  variable {
    name  = "BLOB_CONTAINER_NAME"
    value = var.hub-pa-fe.pipeline.blob_container_name
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "hub-pa-fe-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.hub-pa-fe-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.hub-pa-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-fe-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.hub-pa-fe-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.hub-pa-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-fe-deploy-azurerm-DEV-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.DEV-HUBPA, azuredevops_build_definition.hub-pa-fe-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.DEV-HUBPA.id
  definition_id = azuredevops_build_definition.hub-pa-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

# TODO PRODUCTION
# resource "azuredevops_resource_authorization" "hub-pa-fe-deploy-azurerm-PROD-HUBPA-auth" {
#   depends_on = [azuredevops_serviceendpoint_azurerm.PROD-HUBPA, azuredevops_build_definition.hub-pa-fe-deploy, time_sleep.wait]

#   project_id    = azuredevops_project.project.id
#   resource_id   = azuredevops_serviceendpoint_azurerm.PROD-HUBPA.id
#   definition_id = azuredevops_build_definition.hub-pa-fe-deploy.id
#   authorized    = true
#   type          = "endpoint"
# }
