variable "ade-aa-ms-mock" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "ade-aa-ms-mock"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v1"
      dev = {
        deploy_type                               = "production_slot" #or staging_slot_and_swap
        web_app_name                              = ""
        web_app_resource_group_name               = ""
        healthcheck_endpoint                      = "" #todo
        healthcheck_container_resource_group_name = ""
        healthcheck_container_vnet                = ""
      }
      uat = {
        deploy_type                               = "production_slot" #or staging_slot_and_swap
        web_app_name                              = "cgnonboardingportal-u-aa-mock"
        web_app_resource_group_name               = "cgnonboardingportal-u-api-rg"
        healthcheck_endpoint                      = "/info" #todo
        healthcheck_container_resource_group_name = "cgnonboardingportal-u-vnet-rg"
        healthcheck_container_vnet                = "cgnonboardingportal-u-vnet"
      }
      prod = {
        deploy_type                               = "staging_slot_and_swap" #or production_slot
        web_app_name                              = "cgnonboardingportal-p-aa-mock"
        web_app_resource_group_name               = "cgnonboardingportal-p-api-rg"
        healthcheck_endpoint                      = "/info" #todo
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
resource "azuredevops_build_definition" "ade-aa-ms-mock-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.ade-aa-ms-mock.repository.name}.code-review"
  path       = "\\${var.ade-aa-ms-mock.repository.name}"

  pull_request_trigger {
    initial_branch = var.ade-aa-ms-mock.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.ade-aa-ms-mock.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.ade-aa-ms-mock.repository.organization}/${var.ade-aa-ms-mock.repository.name}"
    branch_name           = var.ade-aa-ms-mock.repository.branch_name
    yml_path              = "${var.ade-aa-ms-mock.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.ade-aa-ms-mock.repository.branch_name
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
resource "azuredevops_resource_authorization" "ade-aa-ms-mock-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.ade-aa-ms-mock-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.ade-aa-ms-mock-code-review.id
  authorized    = true
  type          = "endpoint"
}

# Allow code review pipeline to access Github pr service connection, needed to checkout code from the pull request branch
resource "azuredevops_resource_authorization" "ade-aa-ms-mock-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.ade-aa-ms-mock-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.ade-aa-ms-mock-code-review.id
  authorized    = true
  type          = "endpoint"
}

#
# Deploy pipeline
#

# Define deploy pipeline
resource "azuredevops_build_definition" "ade-aa-ms-mock-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw,
    azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL,
    azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL,
  azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.ade-aa-ms-mock.repository.name}.deploy"
  path       = "\\${var.ade-aa-ms-mock.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.ade-aa-ms-mock.repository.organization}/${var.ade-aa-ms-mock.repository.name}"
    branch_name           = var.ade-aa-ms-mock.repository.branch_name
    yml_path              = "${var.ade-aa-ms-mock.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.ade-aa-ms-mock.repository.branch_name
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
    value          = var.ade-aa-ms-mock.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "DEV_AZURE_SUBSCRIPTION"
    value          = ""
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
    name           = "DEV_DEPLOY_TYPE"
    value          = var.ade-aa-ms-mock.pipeline.dev.deploy_type
    allow_override = false
  }

  variable {
    name           = "UAT_DEPLOY_TYPE"
    value          = var.ade-aa-ms-mock.pipeline.uat.deploy_type
    allow_override = false
  }

  variable {
    name           = "PROD_DEPLOY_TYPE"
    value          = var.ade-aa-ms-mock.pipeline.prod.deploy_type
    allow_override = false
  }

  variable {
    name           = "DEV_WEB_APP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.dev.web_app_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.uat.web_app_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.prod.web_app_name
    allow_override = false
  }

  variable {
    name           = "DEV_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.dev.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.uat.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.prod.web_app_resource_group_name
    allow_override = false
  }


  variable {
    name           = "DEV_HEALTHCHECK_ENDPOINT"
    value          = var.ade-aa-ms-mock.pipeline.dev.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_ENDPOINT"
    value          = var.ade-aa-ms-mock.pipeline.uat.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "PROD_HEALTHCHECK_ENDPOINT"
    value          = var.ade-aa-ms-mock.pipeline.prod.healthcheck_endpoint
    allow_override = false
  }

  variable {
    name           = "DEV_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.dev.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.uat.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "PROD_HEALTHCHECK_CONTAINER_RESOURCE_GROUP_NAME"
    value          = var.ade-aa-ms-mock.pipeline.prod.healthcheck_container_resource_group_name
    allow_override = false
  }

  variable {
    name           = "DEV_HEALTHCHECK_CONTAINER_VNET"
    value          = var.ade-aa-ms-mock.pipeline.dev.healthcheck_container_vnet
    allow_override = false
  }

  variable {
    name           = "UAT_HEALTHCHECK_CONTAINER_VNET"
    value          = var.ade-aa-ms-mock.pipeline.uat.healthcheck_container_vnet
    allow_override = false
  }

  variable {
    name           = "PROD_HEALTHCHECK_CONTAINER_VNET"
    value          = var.ade-aa-ms-mock.pipeline.prod.healthcheck_container_vnet
    allow_override = false
  }

}

# Allow deploy pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "ade-aa-ms-mock-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.ade-aa-ms-mock-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.ade-aa-ms-mock-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Github writable service connection, needed to bump project version and publish a new relase
resource "azuredevops_resource_authorization" "ade-aa-ms-mock-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.ade-aa-ms-mock-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.ade-aa-ms-mock-deploy.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Azure UAT-GCNPORTAL subscription service connection, needed to interact with Azure resources
resource "azuredevops_resource_authorization" "ade-aa-ms-mock-deploy-azurerm-UAT-GCNPORTAL-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL, azuredevops_build_definition.ade-aa-ms-mock-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.id
  definition_id = azuredevops_build_definition.ade-aa-ms-mock-deploy.id
  authorized    = true
  type          = "endpoint"
}
