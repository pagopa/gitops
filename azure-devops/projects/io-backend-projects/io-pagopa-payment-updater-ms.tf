variable "io-pagopa-payment-updater-ms" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-pagopa-payment-updater-ms"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      sonarcloud = {
        # TODO azure devops terraform provider does not support SonarCloud service endpoint
        service_connection = "SONARCLOUD-SERVICE-CONN"
        org                = "pagopa"
        project_key        = "pagopa_io-pagopa-payment-updater-ms"
        project_name       = "io-pagopa-payment-updater-ms"
      }
      prod = {
        webAppName        = "io-p-pagopa-payment-updater-ms"
        resourceGroupName = "io-p-pagopa-payment-updater-backend-rg"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-pagopa-payment-updater-ms-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-pagopa-payment-updater-ms.repository.name}.code-review"
  path       = "\\${var.io-pagopa-payment-updater-ms.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-pagopa-payment-updater-ms.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-pagopa-payment-updater-ms.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-pagopa-payment-updater-ms.repository.organization}/${var.io-pagopa-payment-updater-ms.repository.name}"
    branch_name           = var.io-pagopa-payment-updater-ms.repository.branch_name
    yml_path              = "${var.io-pagopa-payment-updater-ms.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "SONARCLOUD_SERVICE_CONN"
    value          = var.io-pagopa-payment-updater-ms.pipeline.sonarcloud.service_connection
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_ORG"
    value          = var.io-pagopa-payment-updater-ms.pipeline.sonarcloud.org
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_KEY"
    value          = var.io-pagopa-payment-updater-ms.pipeline.sonarcloud.project_key
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_NAME"
    value          = var.io-pagopa-payment-updater-ms.pipeline.sonarcloud.project_name
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-pagopa-payment-updater-ms-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-pagopa-payment-updater-ms-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-sonarcloud-auth" {
  depends_on = [azuredevops_build_definition.io-pagopa-payment-updater-ms-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = local.azuredevops_serviceendpoint_sonarcloud_id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-pagopa-payment-updater-ms-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-pagopa-payment-updater-ms.repository.name}.deploy"
  path       = "\\${var.io-pagopa-payment-updater-ms.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-pagopa-payment-updater-ms.repository.organization}/${var.io-pagopa-payment-updater-ms.repository.name}"
    branch_name           = var.io-pagopa-payment-updater-ms.repository.branch_name
    yml_path              = "${var.io-pagopa-payment-updater-ms.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "GITHUB_CONNECTION"
    value          = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_CONTAINER_REGISTRY"
    value          = azuredevops_serviceendpoint_azurecr.io-azurecr-prod.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_NAME"
    value          = var.io-pagopa-payment-updater-ms.pipeline.prod.webAppName
    allow_override = false
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-pagopa-payment-updater-ms-deploy-azurecr-prod-auth" {
  depends_on = [azuredevops_serviceendpoint_azurecr.io-azurecr-prod, azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.io-azurecr-prod.id
  definition_id = azuredevops_build_definition.io-pagopa-payment-updater-ms-deploy.id
  authorized    = true
  type          = "endpoint"
}
