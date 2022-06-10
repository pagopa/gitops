variable "io-functions-cgn-operator-search" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-functions-cgn-operator-search"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v3"
      uat = {
        deploy_type                               = "production_slot" #or staging_slot_and_swap
        web_app_name                              = "cgnonboardingportal-u-op"
        web_app_resource_group_name               = "cgnonboardingportal-u-search-rg"
        healthcheck_endpoint                      = "https://cgnonboardingportal-u-op.azurewebsites.net/info"
        healthcheck_container_resource_group_name = "cgnonboardingportal-u-vnet-rg"
        healthcheck_container_vnet                = "cgnonboardingportal-u-vnet"
      }
      prod = {
        deploy_type                               = "production_slot" #or staging_slot_and_swap
        web_app_name                              = "cgnonboardingportal-p-op"
        web_app_resource_group_name               = "cgnonboardingportal-p-search-rg"
        healthcheck_endpoint                      = "https://cgnonboardingportal-p-op.azurewebsites.net/info"
        healthcheck_container_resource_group_name = "cgnonboardingportal-p-vnet-rg"
        healthcheck_container_vnet                = "cgnonboardingportal-p-vnet"
      }
    }
  }
}

#
# Code Review pipeline
#

# Define code review pipeline
resource "azuredevops_build_definition" "io-functions-cgn-operator-search-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-functions-cgn-operator-search.repository.name}.code-review"
  path       = "\\${var.io-functions-cgn-operator-search.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-functions-cgn-operator-search.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-functions-cgn-operator-search.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-cgn-operator-search.repository.organization}/${var.io-functions-cgn-operator-search.repository.name}"
    branch_name           = var.io-functions-cgn-operator-search.repository.branch_name
    yml_path              = "${var.io-functions-cgn-operator-search.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DANGER_GITHUB_API_TOKEN"
    secret_value   = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret      = true
    allow_override = false
  }
}

# Allow code review pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "io-functions-cgn-operator-search-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-functions-cgn-operator-search-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-functions-cgn-operator-search-code-review.id
  authorized    = true
  type          = "endpoint"
}

# Allow code review pipeline to access Github pr service connection, needed to checkout code from the pull request branch
resource "azuredevops_resource_authorization" "io-functions-cgn-operator-search-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-functions-cgn-operator-search-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-functions-cgn-operator-search-code-review.id
  authorized    = true
  type          = "endpoint"
}

#
# Deploy pipeline
#

# Define deploy pipeline
resource "azuredevops_build_definition" "io-functions-cgn-operator-search-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-functions-cgn-operator-search.repository.name}.deploy"
  path       = "\\${var.io-functions-cgn-operator-search.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-functions-cgn-operator-search.repository.organization}/${var.io-functions-cgn-operator-search.repository.name}"
    branch_name           = var.io-functions-cgn-operator-search.repository.branch_name
    yml_path              = "${var.io-functions-cgn-operator-search.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-functions-cgn-operator-search.repository.branch_name
    allow_override = false
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
    name           = "CACHE_VERSION_ID"
    value          = var.io-functions-cgn-operator-search.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "UAT_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "UAT_DEPLOY_TYPE"
    value          = var.io-functions-cgn-operator-search.pipeline.uat.deploy_type
    allow_override = false
  }

  variable {
    name           = "PROD_DEPLOY_TYPE"
    value          = var.io-functions-cgn-operator-search.pipeline.prod.deploy_type
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_NAME"
    value          = var.io-functions-cgn-operator-search.pipeline.uat.web_app_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_NAME"
    value          = var.io-functions-cgn-operator-search.pipeline.prod.web_app_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.io-functions-cgn-operator-search.pipeline.uat.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.io-functions-cgn-operator-search.pipeline.prod.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_ENDPOINT"
    value          = var.io-functions-cgn-operator-search.pipeline.uat.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "PROD_HEALTHCHECK_ENDPOINT"
    value          = var.io-functions-cgn-operator-search.pipeline.prod.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.io-functions-cgn-operator-search.pipeline.uat.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.io-functions-cgn-operator-search.pipeline.prod.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_CONTAINER_VNET"
    value          = var.io-functions-cgn-operator-search.pipeline.uat.healthcheck_container_vnet
    allow_override = false
  }

  variable {
    name           = "PROD_HEALTHCHECK_CONTAINER_VNET"
    value          = var.io-functions-cgn-operator-search.pipeline.prod.healthcheck_container_vnet
    allow_override = false
  }
}

# Allow deploy pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "io-functions-cgn-operator-search-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-functions-cgn-operator-search-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-functions-cgn-operator-search-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Github writable service connection, needed to bump project version and publish a new relase
resource "azuredevops_resource_authorization" "io-functions-cgn-operator-search-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-functions-cgn-operator-search-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-functions-cgn-operator-search-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Azure UAT-GCNPORTAL subscription service connection, needed to interact with Azure resources
resource "azuredevops_resource_authorization" "io-functions-cgn-operator-search-deploy-azurerm-UAT-GCNPORTAL-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL, azuredevops_build_definition.io-functions-cgn-operator-search-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.id
  definition_id = azuredevops_build_definition.io-functions-cgn-operator-search-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Azure PROD-GCNPORTAL subscription service connection, needed to interact with Azure resources
resource "azuredevops_resource_authorization" "io-functions-cgn-operator-search-deploy-azurerm-PROD-GCNPORTAL-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL, azuredevops_build_definition.io-functions-cgn-operator-search-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.id
  definition_id = azuredevops_build_definition.io-functions-cgn-operator-search-deploy.id
  authorized    = true
  type          = "endpoint"
}
