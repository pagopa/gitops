variable "io-pay-portal-fe" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-pay-portal"
      branch_name    = "main"
      pipelines_path = "."
    }
    pipeline = {
      cache_version_id                      = "v3"
      blob_container_name                   = "$web"
      endpoint_azure                        = "io-p-cdnendpoint-iopayportal"
      io_pay_portal_api_host                = "https://api.io.italia.it"
      io_pay_portal_api_request_timeout     = "5000"
      io_pay_portal_pay_wl_host             = "https://io-p-cdnendpoint-iopay.azureedge.net"
      io_pay_portal_pay_wl_polling_attempts = "10"
      io_pay_portal_pay_wl_polling_interval = "3000"
      profile_name_cdn_azure                = "io-p-cdn-common"
      resource_group_azure                  = "io-p-rg-common"
      storage_account_name                  = "iopstcdniopayportal" 
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-pay-portal-fe-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "io-pay-portal-fe.code-review"
  path       = "\\${var.io-pay-portal-fe.repository.name}\io-pay-portal-fe"

  pull_request_trigger {
    initial_branch = var.io-pay-portal-fe.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-pay-portal-fe.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-pay-portal-fe.repository.organization}/${var.io-pay-portal-fe.repository.name}"
    branch_name           = var.io-pay-portal-fe.repository.branch_name
    yml_path              = "${var.io-pay-portal-fe.repository.pipelines_path}/io-pay-portal-fe/.devops/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-pay-portal-fe-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-pay-portal-fe-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-pay-portal-fe-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pay-portal-fe-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-pay-portal-fe-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-pay-portal-fe-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-pay-portal-fe-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "io-pay-portal-fe.deploy"
  path       = "\\${var.io-pay-portal-fe.repository.name}\io-pay-portal-fe"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-pay-portal-fe.repository.organization}/${var.io-pay-portal-fe.repository.name}"
    branch_name           = var.io-pay-portal-fe.repository.branch_name
    yml_path              = "${var.io-pay-portal-fe.repository.pipelines_path}/io-pay-portal-fe/.devops/deploy-pipelines.yml"
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
    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
  }

  variable {
    name  = "STAGING_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
  }

  variable {
    name  = "CACHE_VERSION_ID"
    value = var.io-pay-portal-fe.pipeline.cache_version_id
  }

  variable {
    name  = "BLOB_CONTAINER_NAME"
    value = var.io-pay-portal-fe.pipeline.blob_container_name
  }

  variable {
    name  = "ENDPOINT_AZURE"
    value = var.io-pay-portal-fe.pipeline.endpoint_azure
  }

  variable {
    name  = "IO_PAY_PORTAL_API_HOST"
    value = var.io-pay-portal-fe.pipeline.io_pay_portal_api_host
  }

  variable {
    name  = "IO_PAY_PORTAL_API_REQUEST_TIMEOUT"
    value = var.io-pay-portal-fe.pipeline.io_pay_portal_api_request_timeout
  }

  variable {
    name  = "IO_PAY_PORTAL_PAY_WL_HOST"
    value = var.io-pay-portal-fe.pipeline.io_pay_portal_pay_wl_host
  }
  
  variable {
    name  = "IO_PAY_PORTAL_PAY_WL_POLLING_ATTEMPTS"
    value = var.io-pay-portal-fe.pipeline.io_pay_portal_pay_wl_polling_attempts
  }
  
  variable {
    name  = "IO_PAY_PORTAL_PAY_WL_POLLING_INTERVAL"
    value = var.io-pay-portal-fe.pipeline.io_pay_portal_pay_wl_polling_interval
  }
  
  variable {
    name  = "PROFILE_NAME_CDN_AZURE"
    value = var.io-pay-portal-fe.pipeline.profile_name_cdn_azure
  }
    
  variable {
    name  = "RESOURCE_GROUP_AZURE"
    value = var.io-pay-portal-fe.pipeline.resource_group_azure
  }

  variable {
    name  = "STORAGE_ACCOUNT_NAME"
    value = var.io-pay-portal-fe.pipeline.storage_account_name
  }

}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-pay-portal-fe-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-pay-portal-fe-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-pay-portal-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pay-portal-fe-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-pay-portal-fe-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-pay-portal-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pay-portal-fe-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-pay-portal-fe-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-pay-portal-fe-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azurerm_role_assignment" "io-pay-deploy-azurerm-PROD-IO-iopstcdniopayportal" {
  depends_on = [data.azuread_service_principal.service_principals]

  principal_id         = data.azuread_service_principal.service_principals[local.PROD-IO-UID].id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${data.azurerm_key_vault_secret.key_vault_secret["TTDIO-PROD-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-pay-portal-fe.pipeline.resource_group_azure}/providers/Microsoft.Storage/storageAccounts/${var.io-pay-portal-fe.pipeline.production_storage_account_name}"
}
