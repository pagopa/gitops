variable "cgn-onboarding-portal-frontend" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "cgn-onboarding-portal-frontend"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      blob_container_name = "$web"
      cache_version_id    = "v1"
      my_index            = "index.html"
      prod = {
        storage_account_name   = "cgnonboardingportalpsaws"
        profile_name_cdn_azure = "cgnonboardingportal-p-cdn-common"
        endpoint_azure         = "cgnonboardingportal-p-cdnendpoint-frontend"
        resource_group_azure   = "cgnonboardingportal-p-cdn-rg"
      }
      uat = {
        storage_account_name   = "cgnonboardingportalusaws"
        profile_name_cdn_azure = "cgnonboardingportal-u-cdn-common"
        endpoint_azure         = "cgnonboardingportal-u-cdnendpoint-frontend"
        resource_group_azure   = "cgnonboardingportal-u-cdn-rg"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "cgn-onboarding-portal-frontend-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.cgn-onboarding-portal-frontend.repository.name}.code-review"
  path       = "\\${var.cgn-onboarding-portal-frontend.repository.name}"

  pull_request_trigger {
    initial_branch = var.cgn-onboarding-portal-frontend.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.cgn-onboarding-portal-frontend.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.cgn-onboarding-portal-frontend.repository.organization}/${var.cgn-onboarding-portal-frontend.repository.name}"
    branch_name           = var.cgn-onboarding-portal-frontend.repository.branch_name
    yml_path              = "${var.cgn-onboarding-portal-frontend.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "cgn-onboarding-portal-frontend-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.cgn-onboarding-portal-frontend.repository.name}.deploy"
  path       = "\\${var.cgn-onboarding-portal-frontend.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.cgn-onboarding-portal-frontend.repository.organization}/${var.cgn-onboarding-portal-frontend.repository.name}"
    branch_name           = var.cgn-onboarding-portal-frontend.repository.branch_name
    yml_path              = "${var.cgn-onboarding-portal-frontend.repository.pipelines_path}/deploy-pipelines.yml"
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
    name  = "BLOB_CONTAINER_NAME"
    value = var.cgn-onboarding-portal-frontend.pipeline.blob_container_name
  }

  variable {
    name  = "MY_INDEX"
    value = var.cgn-onboarding-portal-frontend.pipeline.my_index
  }

  variable {
    name  = "CACHE_VERSION_ID"
    value = var.cgn-onboarding-portal-frontend.pipeline.cache_version_id
  }

  variable {
    name  = "PROD_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.service_endpoint_name
  }

  variable {
    name  = "PROD_STORAGE_ACCOUNT_NAME"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.storage_account_name
  }

  variable {
    name  = "PROD_ENDPOINT_AZURE"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.endpoint_azure
  }

  variable {
    name  = "PROD_PROFILE_NAME_CDN_AZURE"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.profile_name_cdn_azure
  }

  variable {
    name  = "PROD_RESOURCE_GROUP_AZURE"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.resource_group_azure
  }

  variable {
    name  = "UAT_AZURE_SUBSCRIPTION"
    value = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.service_endpoint_name
  }

  variable {
    name  = "UAT_STORAGE_ACCOUNT_NAME"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.storage_account_name
  }

  variable {
    name  = "UAT_ENDPOINT_AZURE"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.endpoint_azure
  }

  variable {
    name  = "UAT_PROFILE_NAME_CDN_AZURE"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.profile_name_cdn_azure
  }

  variable {
    name  = "UAT_RESOURCE_GROUP_AZURE"
    value = var.cgn-onboarding-portal-frontend.pipeline.prod.resource_group_azure
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

//resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-deploy-azurerm-PROD-GCNPORTAL-auth" {
//  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL, azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy, time_sleep.wait]
//
//  project_id    = azuredevops_project.project.id
//  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.id
//  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy.id
//  authorized    = true
//  type          = "endpoint"
//}

# resource "azurerm_role_assignment" "cgn-onboarding-portal-frontend-deploy-azurerm-PROD-GCNPORTAL-storageaccount" {
#   depends_on = [data.azuread_service_principal.service_principals]

#   principal_id         = data.azuread_service_principal.service_principals[local.PROD-GCNPORTAL-UID].id
#   role_definition_name = "Storage Blob Data Contributor"
#   scope                = "/subscriptions/${data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-PROD-GCNPORTAL-SUBSCRIPTION-ID"].value}/resourceGroups/${var.cgn-onboarding-portal-frontend.pipeline.prod.resource_group_azure}/providers/Microsoft.Storage/storageAccounts/${var.cgn-onboarding-portal-frontend.pipeline.prod.storage_account_name}"
# }

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-deploy-azurerm-UAT-GCNPORTAL-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL, azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Comment for now due two different tenat ad used
//resource "azurerm_role_assignment" "cgn-onboarding-portal-frontend-deploy-azurerm-UAT-GCNPORTAL-storageaccount" {
//  depends_on = [data.azuread_service_principal.service_principals]
//
//  principal_id         = data.azuread_service_principal.service_principals[local.UAT-GCNPORTAL-UID].id
//  role_definition_name = "Storage Blob Data Contributor"
//  scope                = "/subscriptions/${data.azurerm_key_vault_secret.key_vault_secret["PAGOPAIT-UAT-GCNPORTAL-SUBSCRIPTION-ID"].value}/resourceGroups/${var.cgn-onboarding-portal-frontend.pipeline.uat.resource_group_azure}/providers/Microsoft.Storage/storageAccounts/${var.cgn-onboarding-portal-frontend.pipeline.uat.storage_account_name}"
//}
