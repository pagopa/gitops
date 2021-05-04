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
      cache_version_id    = "v1"
      blob_container_name = "$web"
      my_index            = "index.html"
      dev = {
        storage_account_name = "hubpadsa"
        profile_cdn_name     = "hubpa-d-cdn-common"
        endpoint_name        = "hubpa-d-cdnendpoint-frontend"
        resource_group_name  = "hubpa-d-fe-rg"
      }
      uat = {
        storage_account_name = "hubpausa"
        profile_cdn_name     = "hubpa-u-cdn-common"
        endpoint_name        = "hubpa-u-cdnendpoint-frontend"
        resource_group_name  = "hubpa-u-fe-rg"
      }
      prod = {
        storage_account_name = "hubpapsa"
        profile_cdn_name     = "hubpa-p-cdn-common"
        endpoint_name        = "hubpa-p-cdnendpoint-frontend"
        resource_group_name  = "hubpa-p-fe-rg"
      }
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
    name           = "DEFAULT_BRANCH"
    value          = var.hub-pa-fe.repository.branch_name
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
  name       = format("%s.deploy", var.hub-pa-fe.repository.name)
  path       = format("\\%s", var.hub-pa-fe.repository.name)

  repository {
    repo_type             = "GitHub"
    repo_id               = join("/", [var.hub-pa-fe.repository.organization, var.hub-pa-fe.repository.name])
    branch_name           = var.hub-pa-fe.repository.branch_name
    yml_path              = join("/", [var.hub-pa-fe.repository.pipelines_path], ["deploy-pipelines.yml"])
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.hub-pa-fe.repository.branch_name
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
    name           = "CACHE_VERSION_ID"
    value          = var.hub-pa-fe.pipeline.cache_version_id
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
    name           = "DEV_STORAGE_ACCOUNT_NAME"
    value          = var.hub-pa-fe.pipeline.dev.storage_account_name
    allow_override = false
  }

  variable {
    name           = "UAT_STORAGE_ACCOUNT_NAME"
    value          = var.hub-pa-fe.pipeline.uat.storage_account_name
    allow_override = false
  }

  variable {
    name           = "PROD_STORAGE_ACCOUNT_NAME"
    value          = var.hub-pa-fe.pipeline.prod.storage_account_name
    allow_override = false
  }

  variable {
    name           = "DEV_PROFILE_CDN_NAME"
    value          = var.hub-pa-fe.pipeline.dev.profile_cdn_name
    allow_override = false
  }

  variable {
    name           = "UAT_PROFILE_CDN_NAME"
    value          = var.hub-pa-fe.pipeline.uat.profile_cdn_name
    allow_override = false
  }

  variable {
    name           = "PROD_PROFILE_CDN_NAME"
    value          = var.hub-pa-fe.pipeline.prod.profile_cdn_name
    allow_override = false
  }

  variable {
    name           = "DEV_ENDPOINT_NAME"
    value          = var.hub-pa-fe.pipeline.dev.endpoint_name
    allow_override = false
  }

  variable {
    name           = "UAT_ENDPOINT_NAME"
    value          = var.hub-pa-fe.pipeline.uat.endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_ENDPOINT_NAME"
    value          = var.hub-pa-fe.pipeline.prod.endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_RESOURCE_GROUP_NAME"
    value          = var.hub-pa-fe.pipeline.dev.resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_RESOURCE_GROUP_NAME"
    value          = var.hub-pa-fe.pipeline.uat.resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_RESOURCE_GROUP_NAME"
    value          = var.hub-pa-fe.pipeline.prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "BLOB_CONTAINER_NAME"
    value          = var.hub-pa-fe.pipeline.blob_container_name
    allow_override = false
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

resource "azuredevops_resource_authorization" "hub-pa-fe-deploy-azurerm-UAT-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-HUBPA, azuredevops_build_definition.hub-pa-fe-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-HUBPA.id
  definition_id = azuredevops_build_definition.hub-pa-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "hub-pa-fe-deploy-azurerm-PROD-HUBPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-HUBPA, azuredevops_build_definition.hub-pa-fe-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-HUBPA.id
  definition_id = azuredevops_build_definition.hub-pa-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}
