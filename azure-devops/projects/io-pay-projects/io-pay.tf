variable "io-pay" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-pay"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id                = "v3"
      blob_container_name             = "$web"
      endpoint_azure                  = "io-p-cdnendpoint-iopay"
      io_pay_functions_host           = "https://api.io.italia.it"
      io_pay_payment_manager_host     = "https://wisp2.pagopa.gov.it"
      my_index                        = "index.html?p=433"
      production_storage_account_name = "iopstcdniopay"
      profile_name_cdn_azure          = "io-p-cdn-common"
      resource_group_azure            = "io-p-rg-common"
      staging_storage_account_name    = "iopstcdniopay"
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-pay-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-pay.repository.name}.code-review"
  path       = "\\${var.io-pay.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-pay.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-pay.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-pay.repository.organization}/${var.io-pay.repository.name}"
    branch_name           = var.io-pay.repository.branch_name
    yml_path              = "${var.io-pay.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DANGER_GITHUB_API_TOKEN"
    secret_value   = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret      = true
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-pay-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-pay-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-pay-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pay-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-pay-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-pay-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-pay-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-pay.repository.name}.deploy"
  path       = "\\${var.io-pay.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-pay.repository.organization}/${var.io-pay.repository.name}"
    branch_name           = var.io-pay.repository.branch_name
    yml_path              = "${var.io-pay.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "GIT_EMAIL"
    value          = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-EMAIL"].value
    allow_override = false
  }

  variable {
    name           = "GIT_USERNAME"
    value          = data.azurerm_key_vault_secret.key_vault_secret["io-azure-devops-github-USERNAME"].value
    allow_override = false
  }

  variable {
    name           = "GITHUB_CONNECTION"
    value          = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "STAGING_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-pay.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "BLOB_CONTAINER_NAME"
    value          = var.io-pay.pipeline.blob_container_name
    allow_override = false
  }

  variable {
    name           = "ENDPOINT_AZURE"
    value          = var.io-pay.pipeline.endpoint_azure
    allow_override = false
  }

  variable {
    name           = "IO_PAY_FUNCTIONS_HOST"
    value          = var.io-pay.pipeline.io_pay_functions_host
    allow_override = false
  }

  variable {
    name           = "IO_PAY_PAYMENT_MANAGER_HOST"
    value          = var.io-pay.pipeline.io_pay_payment_manager_host
    allow_override = false
  }

  variable {
    name           = "MY_INDEX"
    value          = var.io-pay.pipeline.my_index
    allow_override = false
  }

  variable {
    name           = "PROFILE_NAME_CDN_AZURE"
    value          = var.io-pay.pipeline.profile_name_cdn_azure
    allow_override = false
  }

  variable {
    name           = "RESOURCE_GROUP_AZURE"
    value          = var.io-pay.pipeline.resource_group_azure
    allow_override = false
  }

  variable {
    name           = "STAGING_STORAGE_ACCOUNT_NAME"
    value          = var.io-pay.pipeline.staging_storage_account_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_STORAGE_ACCOUNT_NAME"
    value          = var.io-pay.pipeline.production_storage_account_name
    allow_override = false
  }

}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-pay-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-pay-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-pay-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pay-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-pay-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-pay-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pay-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-pay-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-pay-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azurerm_role_assignment" "io-pay-deploy-azurerm-PROD-IO-iopstcdniopay" {
  depends_on = [data.azuread_service_principal.service_principals]

  principal_id         = data.azuread_service_principal.service_principals[local.PROD-IO-UID].id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = "/subscriptions/${data.azurerm_key_vault_secret.key_vault_secret["TTDIO-PROD-IO-SUBSCRIPTION-ID"].value}/resourceGroups/${var.io-pay.pipeline.resource_group_azure}/providers/Microsoft.Storage/storageAccounts/${var.io-pay.pipeline.production_storage_account_name}"
}
