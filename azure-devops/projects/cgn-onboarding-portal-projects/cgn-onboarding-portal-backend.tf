variable "cgn-onboarding-portal-backend" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "cgn-onboarding-portal-backend"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      sonarcloud = {
        # TODO azure devops terraform provider does not support SonarCloud service endpoint
        service_connection = "SONARCLOUD-SERVICE-CONN"
        org                = "pagopa"
        project_key        = "pagopa_cgn-onboarding-portal-backend"
        project_name       = "cgn-onboarding-portal-backend"
      }
      prod = {
        webAppName = "cgnonboardingportal-p-portal-backend1"
      }
      uat = {
        webAppName = "cgnonboardingportal-u-portal-backend1"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "cgn-onboarding-portal-backend-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.cgn-onboarding-portal-backend.repository.name}.code-review"
  path       = "\\${var.cgn-onboarding-portal-backend.repository.name}"

  pull_request_trigger {
    initial_branch = var.cgn-onboarding-portal-backend.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.cgn-onboarding-portal-backend.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.cgn-onboarding-portal-backend.repository.organization}/${var.cgn-onboarding-portal-backend.repository.name}"
    branch_name           = var.cgn-onboarding-portal-backend.repository.branch_name
    yml_path              = "${var.cgn-onboarding-portal-backend.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "SONARCLOUD_SERVICE_CONN"
    value          = var.cgn-onboarding-portal-backend.pipeline.sonarcloud.service_connection
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_ORG"
    value          = var.cgn-onboarding-portal-backend.pipeline.sonarcloud.org
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_KEY"
    value          = var.cgn-onboarding-portal-backend.pipeline.sonarcloud.project_key
    allow_override = false
  }

  variable {
    name           = "SONARCLOUD_PROJECT_NAME"
    value          = var.cgn-onboarding-portal-backend.pipeline.sonarcloud.project_name
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.cgn-onboarding-portal-backend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.cgn-onboarding-portal-backend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "cgn-onboarding-portal-backend-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.cgn-onboarding-portal-backend.repository.name}.deploy"
  path       = "\\${var.cgn-onboarding-portal-backend.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.cgn-onboarding-portal-backend.repository.organization}/${var.cgn-onboarding-portal-backend.repository.name}"
    branch_name           = var.cgn-onboarding-portal-backend.repository.branch_name
    yml_path              = "${var.cgn-onboarding-portal-backend.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "GITHUB_CONNECTION"
    value          = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PROD_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.service_endpoint_name
    allow_override = false
  }

  # TODO
  # variable {
  #   name  = "PROD_CONTAINER_REGISTRY"
  #   value = azuredevops_serviceendpoint_azurecr.cgnonboardingportal-prod-azurecr.service_endpoint_name
  #   allow_override = false
  # }

  variable {
    name           = "PROD_WEB_APP_NAME"
    value          = var.cgn-onboarding-portal-backend.pipeline.prod.webAppName
    allow_override = false
  }

  variable {
    name           = "UAT_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "UAT_CONTAINER_REGISTRY"
    value          = azuredevops_serviceendpoint_azurecr.cgnonboardingportal-uat-azurecr.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "UAT_WEB_APP_NAME"
    value          = var.cgn-onboarding-portal-backend.pipeline.uat.webAppName
    allow_override = false
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.cgn-onboarding-portal-backend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.cgn-onboarding-portal-backend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-deploy-azurerm-UAT-CGNPORTAL-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL, azuredevops_build_definition.cgn-onboarding-portal-backend-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.UAT-GCNPORTAL.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-deploy-azurerm-PROD-CGNPORTAL-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL, azuredevops_build_definition.cgn-onboarding-portal-backend-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-GCNPORTAL.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-deploy-azurecr-uat-auth" {
  depends_on = [azuredevops_serviceendpoint_azurecr.cgnonboardingportal-uat-azurecr, azuredevops_build_definition.cgn-onboarding-portal-backend-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurecr.cgnonboardingportal-uat-azurecr.id
  definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

# TODO
# resource "azuredevops_resource_authorization" "cgn-onboarding-portal-backend-deploy-azurecr-prod-auth" {
#   depends_on = [azuredevops_serviceendpoint_azurecr.cgnonboardingportal-prod-azurecr, azuredevops_build_definition.cgn-onboarding-portal-backend-deploy, time_sleep.wait]

#   project_id    = azuredevops_project.project.id
#   resource_id   = azuredevops_serviceendpoint_azurecr.cgnonboardingportal-prod-azurecr.id
#   definition_id = azuredevops_build_definition.cgn-onboarding-portal-backend-deploy.id
#   authorized    = true
#   type          = "endpoint"
# }
