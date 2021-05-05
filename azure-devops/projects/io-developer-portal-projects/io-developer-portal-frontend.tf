variable "io-developer-portal-frontend" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-developer-portal-frontend"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id                  = "v1"
      io_developer_portal_apim_base_url = "https://api.io.italia.it/api/v1"
      io_developer_portal_backend       = "https://developerportal-backend.io.italia.it"
      io_developer_portal_base_url      = "/"
      io_developer_portal_logo_path     = "https://assets.cdn.io.italia.it/logos" #to verify https://assets.cdn.io.italia.it/logos 
      io_developer_portal_port          = "80"
      io_developer_portal_public_path   = "/"
      dev = {
        storage_account_name = ""
        profile_cdn_name     = ""
        endpoint_name        = ""
        resource_group_name  = ""
      }
      prod = {
        storage_account_name = "iopstcdndeveloperportal"
        profile_cdn_name     = "io-p-cdn-common"
        endpoint_name        = "io-p-cdnendpoint-developerportal"
        resource_group_name  = "io-p-rg-common"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-developer-portal-frontend-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-developer-portal-frontend.repository.name}.code-review"
  path       = "\\${var.io-developer-portal-frontend.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-developer-portal-frontend.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-developer-portal-frontend.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-developer-portal-frontend.repository.organization}/${var.io-developer-portal-frontend.repository.name}"
    branch_name           = var.io-developer-portal-frontend.repository.branch_name
    yml_path              = "${var.io-developer-portal-frontend.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-developer-portal-frontend.repository.branch_name
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
resource "azuredevops_resource_authorization" "io-developer-portal-frontend-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-developer-portal-frontend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-developer-portal-frontend-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-developer-portal-frontend-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-developer-portal-frontend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-developer-portal-frontend-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-developer-portal-frontend-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-developer-portal-frontend.repository.name}.deploy"
  path       = "\\${var.io-developer-portal-frontend.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-developer-portal-frontend.repository.organization}/${var.io-developer-portal-frontend.repository.name}"
    branch_name           = var.io-developer-portal-frontend.repository.branch_name
    yml_path              = "${var.io-developer-portal-frontend.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-developer-portal-frontend.repository.branch_name
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
    value          = var.io-developer-portal-frontend.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "IO_DEVELOPER_PORTAL_APIM_BASE_URL"
    value          = var.io-developer-portal-frontend.pipeline.io_developer_portal_apim_base_url
    allow_override = false
  }

  variable {
    name           = "IO_DEVELOPER_PORTAL_BACKEND"
    value          = var.io-developer-portal-frontend.pipeline.io_developer_portal_backend
    allow_override = false
  }

  variable {
    name           = "IO_DEVELOPER_PORTAL_BASE_URL"
    value          = var.io-developer-portal-frontend.pipeline.io_developer_portal_base_url
    allow_override = false
  }

  variable {
    name           = "IO_DEVELOPER_PORTAL_LOGO_PATH"
    value          = var.io-developer-portal-frontend.pipeline.io_developer_portal_logo_path
    allow_override = false
  }

  variable {
    name           = "IO_DEVELOPER_PORTAL_PORT"
    value          = var.io-developer-portal-frontend.pipeline.io_developer_portal_port
    allow_override = false
  }

  variable {
    name           = "IO_DEVELOPER_PORTAL_PUBLIC_PATH"
    value          = var.io-developer-portal-frontend.pipeline.io_developer_portal_public_path
    allow_override = false
  }

  variable {
    name           = "PROD_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_AZURE_SUBSCRIPTION"
    value          = ""
    allow_override = false
  }

  variable {
    name           = "PROD_ENDPOINT_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_ENDPOINT_NAME"
    value          = var.io-developer-portal-frontend.pipeline.dev.endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_PROFILE_CDN_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.profile_cdn_name
    allow_override = false
  }

  variable {
    name           = "DEV_PROFILE_CDN_NAME"
    value          = var.io-developer-portal-frontend.pipeline.dev.profile_cdn_name
    allow_override = false
  }

  variable {
    name           = "PROD_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "DEV_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.dev.resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "DEV_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.dev.resource_group_name
    allow_override = false
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-developer-portal-frontend-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-developer-portal-frontend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-developer-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-developer-portal-frontend-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-developer-portal-frontend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-developer-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-developer-portal-frontend-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-developer-portal-frontend-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-developer-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

# resource "azurerm_role_assignment" "io-developer-portal-frontend-deploy-azurerm-DEV-IO-iopstcdniopayportal" {
#   depends_on = [data.azuread_service_principal.service_principals]

#   principal_id         = data.azuread_service_principal.service_principals[local.DEV-IO-UID].id
#   role_definition_name = "Storage Blob Data Contributor"
#   scope                = "/subscriptions/${module.secrets.values["TTDIO-DEV-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-developer-portal-frontend.pipeline.dev.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.io-developer-portal-frontend.pipeline.dev.storage_account_name}"
# }

resource "azurerm_role_assignment" "io-developer-portal-frontend-deploy-azurerm-PROD-IO-iopstcdniopayportal" {
  depends_on = [data.azuread_service_principal.service_principals]

  principal_id         = data.azuread_service_principal.service_principals[local.PROD-IO-UID].id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${module.secrets.values["TTDIO-PROD-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-developer-portal-frontend.pipeline.prod.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.io-developer-portal-frontend.pipeline.prod.storage_account_name}"
}
