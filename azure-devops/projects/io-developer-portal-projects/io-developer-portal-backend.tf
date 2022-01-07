variable "io-developer-portal-backend" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-developer-portal-backend"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id = "v1"
      prod = {
        web_app_name                = "io-p-app-devportal-be"
        web_app_resource_group_name = "io-p-selfcare-be-rg"
      }
      selfcare_prod = {
        web_app_name                = "io-p-app-selfcare-be"
        web_app_resource_group_name = "io-p-selfcare-be-rg"
      }
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-developer-portal-backend-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-developer-portal-backend.repository.name}.code-review"
  path       = "\\${var.io-developer-portal-backend.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-developer-portal-backend.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-developer-portal-backend.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-developer-portal-backend.repository.organization}/${var.io-developer-portal-backend.repository.name}"
    branch_name           = var.io-developer-portal-backend.repository.branch_name
    yml_path              = "${var.io-developer-portal-backend.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-developer-portal-backend.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-developer-portal-backend.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "DANGER_GITHUB_API_TOKEN"
    secret_value   = module.secrets.values["DANGER-GITHUB-API-TOKEN"].value
    is_secret      = true
    allow_override = false
  }
}

# code review serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-developer-portal-backend-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-developer-portal-backend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-developer-portal-backend-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-developer-portal-backend-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-developer-portal-backend-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-developer-portal-backend-code-review.id
  authorized    = true
  type          = "endpoint"
}

# deploy
resource "azuredevops_build_definition" "io-developer-portal-backend-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-developer-portal-backend.repository.name}.deploy"
  path       = "\\${var.io-developer-portal-backend.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-developer-portal-backend.repository.organization}/${var.io-developer-portal-backend.repository.name}"
    branch_name           = var.io-developer-portal-backend.repository.branch_name
    yml_path              = "${var.io-developer-portal-backend.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-developer-portal-backend.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-developer-portal-backend.pipeline.cache_version_id
    allow_override = false
  }

  variable {
    name           = "GIT_EMAIL"
    value          = module.secrets.values["io-azure-devops-github-EMAIL"].value
    allow_override = false
  }

  variable {
    name           = "GIT_USERNAME"
    value          = module.secrets.values["io-azure-devops-github-USERNAME"].value
    allow_override = false
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
    name           = "PROD_WEB_APP_NAME"
    value          = var.io-developer-portal-backend.pipeline.prod.web_app_name
    allow_override = false
  }

  variable {
    name           = "PROD_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-backend.pipeline.prod.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name           = "SELFCARE_PROD_WEB_APP_NAME"
    value          = var.io-developer-portal-backend.pipeline.selfcare_prod.web_app_name
    allow_override = false
  }

  variable {
    name           = "SELFCARE_PROD_WEB_APP_RESOURCE_GROUP_NAME"
    value          = var.io-developer-portal-backend.pipeline.selfcare_prod.web_app_resource_group_name
    allow_override = false
  }

  variable {
    name  = "AGENT_POOL"
    value = local.agent_pool
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-developer-portal-backend-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-developer-portal-backend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-developer-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-developer-portal-backend-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-developer-portal-backend-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-developer-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-developer-portal-backend-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-developer-portal-backend-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-developer-portal-backend-deploy.id
  authorized    = true
  type          = "endpoint"
}
