variable "mock.ec-services" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "mock.ec-services-test"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v1"
      # dev = {
      #   deploy_type                               = "production_slot" #or staging_slot_and_swap
      #   web_app_name                              = ""
      #   web_app_resource_group_name               = ""
      #   healthcheck_endpoint                      = "" #todo
      #   healthcheck_container_resource_group_name = ""
      #   healthcheck_container_vnet                = ""
      # }
      uat = {
        deploy_type                               = "production_slot" #or staging_slot_and_swap
        web_app_name                              = "ecpa-d-partner-app-service"
        web_app_resource_group_name               = "ecpa-d-app-rg"
        healthcheck_endpoint                      = "" #todo
        # healthcheck_container_resource_group_name = "cgnonboardingportal-u-vnet-rg"
        # healthcheck_container_vnet                = "cgnonboardingportal-u-vnet"
      }
    }
  }
}

#
# Code Review pipeline
#

# Define code review pipeline
resource "azuredevops_build_definition" "mock.ec-services-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.mock.ec-services.repository.name}.code-review"
  path       = "\\${var.mock.ec-services.repository.name}"

  pull_request_trigger {
    initial_branch = var.mock.ec-services.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.mock.ec-services.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.mock.ec-services.repository.organization}/${var.mock.ec-services.repository.name}"
    branch_name           = var.mock.ec-services.repository.branch_name
    yml_path              = "${var.mock.ec-services.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.mock.ec-services.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "DANGER_GITHUB_API_TOKEN"
    secret_value   = data.azurerm_key_vault_secret.key_vault_secret["DANGER-GITHUB-API-TOKEN"].value
    is_secret      = true
    allow_override = false
  }
}

# Allow code review pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "mock.ec-services-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.mock.ec-services-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.mock.ec-services-code-review.id
  authorized    = true
  type          = "endpoint"
}

# Allow code review pipeline to access Github pr service connection, needed to checkout code from the pull request branch
resource "azuredevops_resource_authorization" "mock.ec-services-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.mock.ec-services-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.mock.ec-services-code-review.id
  authorized    = true
  type          = "endpoint"
}

#
# Deploy pipeline
#

# Define deploy pipeline
resource "azuredevops_build_definition" "mock.ec-services-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw,
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA,
  azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.mock.ec-services.repository.name}.deploy"
  path       = "\\${var.mock.ec-services.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.mock.ec-services.repository.organization}/${var.mock.ec-services.repository.name}"
    branch_name           = var.mock.ec-services.repository.branch_name
    yml_path              = "${var.mock.ec-services.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.mock.ec-services.repository.branch_name
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
    value          = var.mock.ec-services.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "DEV_AZURE_SUBSCRIPTION"
    value          = ""
    allow_override = false
  }

  variable {
    name           = "UAT_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_DEPLOY_TYPE"
    value          = var.mock.ec-services.pipeline.dev.deploy_type
    allow_override = false
  }

  variable {
    name           = "UAT_DEPLOY_TYPE"
    value          = var.mock.ec-services.pipeline.uat.deploy_type
    allow_override = false
  }

  variable {
    name           = "DEV_WEB_APP_NAME"
    value          = var.mock.ec-services.pipeline.dev.web_app_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_NAME"
    value          = var.mock.ec-services.pipeline.uat.web_app_name
    allow_override = false
  }

  variable {
    name           = "DEV_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.mock.ec-services.pipeline.dev.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.mock.ec-services.pipeline.uat.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "DEV_HEALTHCHECK_ENDPOINT"
    value          = var.mock.ec-services.pipeline.dev.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_ENDPOINT"
    value          = var.mock.ec-services.pipeline.uat.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "DEV_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.mock.ec-services.pipeline.dev.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.mock.ec-services.pipeline.uat.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "DEV_HEALTHCHECK_CONTAINER_VNET"
    value          = var.mock.ec-services.pipeline.dev.healthcheck_container_vnet
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_CONTAINER_VNET"
    value          = var.mock.ec-services.pipeline.uat.healthcheck_container_vnet
    allow_override = false
  }

}

# Allow deploy pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "mock.ec-services-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.mock.ec-services-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.mock.ec-services-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Github writable service connection, needed to bump project version and publish a new relase
resource "azuredevops_resource_authorization" "mock.ec-services-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.mock.ec-services-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.mock.ec-services-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Azure UAT-PAGOPA subscription service connection, needed to interact with Azure resources
resource "azuredevops_resource_authorization" "mock.ec-services-deploy-azurerm-UAT-PAGOPA-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-PAGOPA, azuredevops_build_definition.mock.ec-services-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id
  definition_id = azuredevops_build_definition.mock.ec-services-deploy.id
  authorized    = true
  type          = "endpoint"
}

