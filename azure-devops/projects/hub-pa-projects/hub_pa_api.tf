variable "hub-pa-api" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "hub-pa-api"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v1"
      sonarcloud = {
        # TODO azure devops terraform provider does not support SonarCloud service endpoint
        service_connection = "SONARCLOUD-SERVICE-CONN"
        org                = "pagopa"
        project_key        = "pagopa_hub-pa-api"
        project_name       = "hub-pa-api"
      }
      dev = {
        web_app_name = "hubpa-d-service-ms"
      }
      uat = {
        web_app_name = "hubpa-u-service-ms"
      }
      prod = {
        web_app_name = "hubpa-p-service-ms"
      }
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
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "SONARCLOUD_SERVICE_CONN"
    value          = var.hub-pa-api.pipeline.sonarcloud.service_connection
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_ORG"
    value          = var.hub-pa-api.pipeline.sonarcloud.org
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_KEY"
    value          = var.hub-pa-api.pipeline.sonarcloud.project_key
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_NAME"
    value          = var.hub-pa-api.pipeline.sonarcloud.project_name
    allow_override = false
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

resource "azuredevops_resource_authorization" "hub-pa-api-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr,
    azuredevops_build_definition.hub-pa-api-code-review,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
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
    name           = "CACHE_VERSION_ID"
    value          = var.hub-pa-api.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "DEV_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.DEV-HUBPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "UAT_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.UAT-HUBPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-HUBPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_CONTAINER_REGISTRY"
    value          = azuredevops_serviceendpoint_azurecr.hubpa-azurecr-dev.service_endpoint_name
    allow_override = false
  }

  # TODO UAT missing container registry
  # variable {
  #   name           = "UAT_CONTAINER_REGISTRY"
  #   value          = azuredevops_serviceendpoint_azurecr.hubpa-azurecr-uat.service_endpoint_name
  #   allow_override = false
  # }

  variable {
    name           = "PROD_CONTAINER_REGISTRY"
    value          = azuredevops_serviceendpoint_azurecr.hubpa-azurecr-prod.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_WEB_APP_NAME"
    value          = var.hub-pa-api.pipeline.dev.web_app_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_NAME"
    value          = var.hub-pa-api.pipeline.uat.web_app_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_NAME"
    value          = var.hub-pa-api.pipeline.prod.web_app_name
    allow_override = false
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

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurerm-UAT-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-HUBPA, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-HUBPA.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurerm-PROD-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-HUBPA, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-HUBPA.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurecr-DEV-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurecr.hubpa-azurecr-dev, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.hubpa-azurecr-dev.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}

# TODO UAT missing container registry
# resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurecr-UAT-HUBPA-auth" {
#   depends_on = [azuredevops_serviceendpoint_azurecr.hubpa-azurecr-uat, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

#   project_id    = azuredevops_project.project.id
#   resource_id   = azuredevops_serviceendpoint_azurecr.hubpa-azurecr-uat.id
#   definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
#   authorized    = true
#   type          = "endpoint"
# }

resource "azuredevops_resource_authorization" "hub-pa-api-deploy-azurecr-PROD-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurecr.hubpa-azurecr-prod, azuredevops_build_definition.hub-pa-api-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.hubpa-azurecr-prod.id
  definition_id = azuredevops_build_definition.hub-pa-api-deploy.id
  authorized    = true
  type          = "endpoint"
}
