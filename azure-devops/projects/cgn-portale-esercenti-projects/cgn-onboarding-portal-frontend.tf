locals {
  repository_name           = "cgn-onboarding-portal-frontend"
  repository_repo_id        = "pagopa/${local.repository_name}"
  repository_branch_name    = "main"
  repository_pipelines_path = ".devops"
  build_path                = "\\${local.repository_name}"
  pipeline_cache_version_id = "v1"
  # TODO
  pipeline_production_storage_account_name = ""
  pipeline_blob_container_name             = ""
  pipeline_staging_storage_account_name    = ""
}

# code review
resource "azuredevops_build_definition" "cgn-onboarding-portal-frontend-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "code-review"
  path       = local.build_path

  pull_request_trigger {
    initial_branch = local.repository_branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [local.repository_branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = local.repository_repo_id
    branch_name           = local.repository_branch_name
    yml_path              = "${local.repository_pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  }

  variable {
    name         = "DANGER_GITHUB_API_TOKEN"
    secret_value = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret    = true
  }
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-code-review-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "cgn-onboarding-portal-frontend-code-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "deploy"
  path       = local.build_path

  repository {
    repo_type             = "GitHub"
    repo_id               = local.repository_repo_id
    branch_name           = local.repository_branch_name
    yml_path              = "${local.repository_pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }


  # TODO vars
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
    value = local.pipeline_cache_version_id
  }



  //  variable {
  //    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
  //    value = azuredevops_serviceendpoint_azurerm.PROD-CGN.service_endpoint_name
  //  }
  //
  //  variable {
  //    name  = "PRODUCTION_STORAGE_ACCOUNT_NAME"
  //    value = local.pipeline_production_storage_account_name
  //  }
  //
  //  variable {
  //    name  = "BLOB_CONTAINER_NAME"
  //    value = local.pipeline_blob_container_name
  //  }
  //  variable {
  //    name  = "STAGING_AZURE_SUBSCRIPTION"
  //    value = azuredevops_serviceendpoint_azurerm.STAGING-CGN.service_endpoint_name
  //  }
  //
  //  variable {
  //    name  = "STAGING_STORAGE_ACCOUNT_NAME"
  //    value = local.pipeline_staging_storage_account_name
  //  }
}

resource "azuredevops_resource_authorization" "hub-pa-api-code-deploy-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.cgn-onboarding-portal-frontend-code-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-code-deploy.id
  authorized    = true
  type          = "endpoint"
}
