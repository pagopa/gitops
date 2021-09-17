variable "pagopa-api-config" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "pagopa-api-config"
      branch_name    = "main"
      pipelines_path = ".devops"
    }
    pipeline   = {
      sonarcloud = {
        # TODO azure devops terraform provider does not support SonarCloud service endpoint
        service_connection = "SONARCLOUD-SERVICE-CONN"
        org                = "pagopa"
        project_key        = "pagopa_pagopa-api-config"
        project_name       = "pagopa-api-config"
      }
      prod       = {
        web_app_name = "pagopa-p-app-api-config"
      }
      uat        = {
        web_app_name = "pagopa-u-app-api-config"
      }
      dev        = {
        web_app_name = "pagopa-d-app-api-config"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "pagopa-api-config-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.pagopa-api-config.repository.name}.code-review"
  path       = "\\${var.pagopa-api-config.repository.name}"

  pull_request_trigger {
    initial_branch = var.pagopa-api-config.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.pagopa-api-config.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.pagopa-api-config.repository.organization}/${var.pagopa-api-config.repository.name}"
    branch_name           = var.pagopa-api-config.repository.branch_name
    yml_path              = "${var.pagopa-api-config.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "SONARCLOUD_SERVICE_CONN"
    value          = var.pagopa-api-config.pipeline.sonarcloud.service_connection
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_ORG"
    value          = var.pagopa-api-config.pipeline.sonarcloud.org
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_KEY"
    value          = var.pagopa-api-config.pipeline.sonarcloud.project_key
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_NAME"
    value          = var.pagopa-api-config.pipeline.sonarcloud.project_name
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "pagopa-api-config-code-review-github-ro-auth" {
  depends_on = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro,
    azuredevops_build_definition.pagopa-api-config-code-review, azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.pagopa-api-config-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-code-review-github-pr-auth" {
  depends_on = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-pr,
    azuredevops_build_definition.pagopa-api-config-code-review, azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.pagopa-api-config-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "pagopa-api-config-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.pagopa-api-config.repository.name}.deploy"
  path       = "\\${var.pagopa-api-config.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.pagopa-api-config.repository.organization}/${var.pagopa-api-config.repository.name}"
    branch_name           = var.pagopa-api-config.repository.branch_name
    yml_path              = "${var.pagopa-api-config.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "GITHUB_CONNECTION"
    value          = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    allow_override = false
  }


  variable {
    name           = "DEV_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "UAT_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-PAGOPA.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_WEB_APP_NAME"
    value          = var.pagopa-api-config.pipeline.dev.web_app_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_NAME"
    value          = var.pagopa-api-config.pipeline.uat.web_app_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_NAME"
    value          = var.pagopa-api-config.pipeline.prod.web_app_name
    allow_override = false
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-github-ro-auth" {
  depends_on = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.pagopa-api-config-deploy,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-github-rw-auth" {
  depends_on = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.pagopa-api-config-deploy,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}


resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-azurerm-DEV-PAGOPA-auth" {
  depends_on = [
    azuredevops_serviceendpoint_azurerm.DEV-PAGOPA, azuredevops_build_definition.pagopa-api-config-deploy,
    time_sleep.wait
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.DEV-PAGOPA.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-azurerm-UAT-PAGOPA-auth" {
  depends_on = [
    azuredevops_serviceendpoint_azurerm.UAT-PAGOPA, azuredevops_build_definition.pagopa-api-config-deploy,
    time_sleep.wait
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-PAGOPA.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-azurerm-PROD-PAGOPA-auth" {
  depends_on = [
    azuredevops_serviceendpoint_azurerm.PROD-PAGOPA, azuredevops_build_definition.pagopa-api-config-deploy,
    time_sleep.wait
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-PAGOPA.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}


resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-azurecr-dev-auth" {
  depends_on = [
    azuredevops_serviceendpoint_azurecr.pagopa-dev-azurecr, azuredevops_build_definition.pagopa-api-config-deploy,
    time_sleep.wait
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.pagopa-dev-azurecr.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-azurecr-uat-auth" {
  depends_on = [
    azuredevops_serviceendpoint_azurecr.pagopa-uat-azurecr, azuredevops_build_definition.pagopa-api-config-deploy,
    time_sleep.wait
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.pagopa-uat-azurecr.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "pagopa-api-config-deploy-azurecr-prod-auth" {
  depends_on = [
    azuredevops_serviceendpoint_azurecr.pagopa-prod-azurecr, azuredevops_build_definition.pagopa-api-config-deploy,
    time_sleep.wait
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.pagopa-prod-azurecr.id
  definition_id = azuredevops_build_definition.pagopa-api-config-deploy.id
  authorized    = true
  type          = "endpoint"
}
