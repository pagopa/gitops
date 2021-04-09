variable "cgn-onboarding-portal-frontend" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "cgn-onboarding-portal-frontend"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      # TODO
      production_storage_account_name = ""
      blob_container_name             = ""
      staging_storage_account_name    = ""
      cache_version_id                = "v1"
    }
  }
}

# code review
resource "azuredevops_build_definition" "cgn-onboarding-portal-frontend-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_project.project]

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

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-code-review-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.cgn-onboarding-portal-frontend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
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
    value = var.cgn-onboarding-portal-frontend.pipeline.cache_version_id
  }



  //    variable {
  //      name  = "PRODUCTION_AZURE_SUBSCRIPTION"
  //      value = azuredevops_serviceendpoint_azurerm.PROD-CGN.service_endpoint_name
  //    }

  variable {
    name  = "PRODUCTION_STORAGE_ACCOUNT_NAME"
    value = var.cgn-onboarding-portal-frontend.pipeline.production_storage_account_name
  }

  variable {
    name  = "BLOB_CONTAINER_NAME"
    value = var.cgn-onboarding-portal-frontend.pipeline.blob_container_name
  }
  //    variable {
  //      name  = "STAGING_AZURE_SUBSCRIPTION"
  //      value = azuredevops_serviceendpoint_azurerm.STAGING-CGN.service_endpoint_name
  //    }

  variable {
    name  = "STAGING_STORAGE_ACCOUNT_NAME"
    value = var.cgn-onboarding-portal-frontend.pipeline.staging_storage_account_name
  }
}


resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-deploy-github-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy.id
  authorized    = true
  type          = "endpoint"
}

//resource "azuredevops_resource_authorization" "cgn-onboarding-portal-frontend-deploy-azure-auth" {
//  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-CGN, azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy, time_sleep.wait]
//
//  project_id    = azuredevops_project.project.id
//  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-CGN.id
//  definition_id = azuredevops_build_definition.cgn-onboarding-portal-frontend-deploy.id
//  authorized    = true
//  type          = "endpoint"
//}
