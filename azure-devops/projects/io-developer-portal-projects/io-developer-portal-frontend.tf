variable "io-developer-portal-frontend" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-developer-portal-frontend"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id    = "v1"
      blob_container_name = "$web"
      apim_base_url       = "https://api.io.italia.it/api/v1"
      base_url            = "/"
      logo_path           = "https://iopstcdnassets.blob.core.windows.net"
      port                = "80"
      public_path         = "/"

      prod = {
        storage_account_name = "iopstcdndeveloperportal"
        profile_cdn_name     = "io-p-cdn-common"
        endpoint_name        = "io-p-cdnendpoint-developerportal"
        resource_group_name  = "io-p-rg-common"
        backend_url          = "https://developerportal-backend.io.italia.it"
      }

      selfcare_prod = {
        storage_account_name = "iopselfcaresa"
        profile_cdn_name     = "io-p-selfcare-cdn-profile"
        endpoint_name        = "io-p-selfcare-cdn-endpoint"
        resource_group_name  = "io-p-selfcare-fe-rg"
        backend_url          = "https://api.io.selfcare.pagopa.it"
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
    name           = "BLOB_CONTAINER_NAME"
    value          = var.io-developer-portal-frontend.pipeline.blob_container_name
    allow_override = false
  }

  variable {
    name           = "APIM_BASE_URL"
    value          = var.io-developer-portal-frontend.pipeline.apim_base_url
    allow_override = false
  }

  variable {
    name           = "BASE_URL"
    value          = var.io-developer-portal-frontend.pipeline.base_url
    allow_override = false
  }

  variable {
    name           = "LOGO_PATH"
    value          = var.io-developer-portal-frontend.pipeline.logo_path
    allow_override = false
  }

  variable {
    name           = "PORT"
    value          = var.io-developer-portal-frontend.pipeline.port
    allow_override = false
  }

  variable {
    name           = "PUBLIC_PATH"
    value          = var.io-developer-portal-frontend.pipeline.public_path
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
    name           = "PROD_STORAGE_ACCOUNT_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.storage_account_name
    allow_override = false
  }

  variable {
    name           = "PROD_ENDPOINT_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_PROFILE_CDN_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.profile_cdn_name
    allow_override = false
  }


  variable {
    name           = "PROD_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_BACKEND_URL"
    value          = var.io-developer-portal-frontend.pipeline.prod.backend_url
    allow_override = false
  }


  variable {
    name           = "SELFCARE_PROD_STORAGE_ACCOUNT_NAME"
    value          = var.io-developer-portal-frontend.pipeline.selfcare_prod.storage_account_name
    allow_override = false
  }

  variable {
    name           = "SELFCARE_PROD_ENDPOINT_NAME"
    value          = var.io-developer-portal-frontend.pipeline.selfcare_prod.endpoint_name
    allow_override = false
  }

  variable {
    name           = "SELFCARE_PROD_PROFILE_CDN_NAME"
    value          = var.io-developer-portal-frontend.pipeline.selfcare_prod.profile_cdn_name
    allow_override = false
  }


  variable {
    name           = "SELFCARE_PROD_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.selfcare_prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "SELFCARE_PROD_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-frontend.pipeline.selfcare_prod.resource_group_name
    allow_override = false
  }

  variable {
    name           = "SELFCARE_PROD_BACKEND_URL"
    value          = var.io-developer-portal-frontend.pipeline.selfcare_prod.backend_url
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

resource "azurerm_role_assignment" "io-developer-portal-frontend-deploy-azurerm-PROD-IO-iopstcdniopayportal" {
  depends_on = [data.azuread_service_principal.service_principal_PROD-IO]

  principal_id         = data.azuread_service_principal.service_principal_PROD-IO.id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-developer-portal-frontend.pipeline.prod.resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.io-developer-portal-frontend.pipeline.prod.storage_account_name}"
}
