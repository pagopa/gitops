variable "io-selfcare-importadesioni" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-selfcare-importadesioni"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      cache_version_id               = "v1"
      production_resource_group_name = "io-p-selfcare-importadesioni-rg"
      production_app_name            = "io-p-importadesioni-fn"
      dev_resource_group_name        = "io-d-selfcare-importadesioni-rg"
      dev_app_name                   = "io-d-importadesioni-fn"
    }
  }
}

# code review
resource "azuredevops_build_definition" "io-selfcare-importadesioni-code-review" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-selfcare-importadesioni.repository.name}.code-review"
  path       = "\\${var.io-selfcare-importadesioni.repository.name}"

  pull_request_trigger {
    initial_branch = var.io-selfcare-importadesioni.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-selfcare-importadesioni.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-selfcare-importadesioni.repository.organization}/${var.io-selfcare-importadesioni.repository.name}"
    branch_name           = var.io-selfcare-importadesioni.repository.branch_name
    yml_path              = "${var.io-selfcare-importadesioni.repository.pipelines_path}/code-review-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-selfcare-importadesioni.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-selfcare-importadesioni.pipeline.cache_version_id
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
resource "azuredevops_resource_authorization" "io-selfcare-importadesioni-code-review-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-selfcare-importadesioni-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-selfcare-importadesioni-code-review.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-selfcare-importadesioni-code-review-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_build_definition.io-selfcare-importadesioni-code-review, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-selfcare-importadesioni-code-review.id
  authorized    = true
  type          = "endpoint"
}


# deploy
resource "azuredevops_build_definition" "io-selfcare-importadesioni-deploy" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = "${var.io-selfcare-importadesioni.repository.name}.deploy"
  path       = "\\${var.io-selfcare-importadesioni.repository.name}"

  repository {
    repo_type             = "GitHub"
    repo_id               = "${var.io-selfcare-importadesioni.repository.organization}/${var.io-selfcare-importadesioni.repository.name}"
    branch_name           = var.io-selfcare-importadesioni.repository.branch_name
    yml_path              = "${var.io-selfcare-importadesioni.repository.pipelines_path}/deploy-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  }

  variable {
    name           = "DEFAULT_BRANCH"
    value          = var.io-selfcare-importadesioni.repository.branch_name
    allow_override = false
  }

  variable {
    name           = "CACHE_VERSION_ID"
    value          = var.io-selfcare-importadesioni.pipeline.cache_version_id
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
    name           = "PRODUCTION_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_APP_NAME"
    value          = var.io-selfcare-importadesioni.pipeline.production_app_name
    allow_override = false
  }

  variable {
    name           = "PRODUCTION_RESOURCE_GROUP_NAME"
    value          = var.io-selfcare-importadesioni.pipeline.production_resource_group_name
    allow_override = false
  }


  variable {
    name           = "DEV_AZURE_SUBSCRIPTION"
    value          = azuredevops_serviceendpoint_azurerm.DEV-IO.service_endpoint_name
    allow_override = false
  }

  variable {
    name           = "DEV_APP_NAME"
    value          = var.io-selfcare-importadesioni.pipeline.dev_app_name
    allow_override = false
  }

  variable {
    name           = "DEV_RESOURCE_GROUP_NAME"
    value          = var.io-selfcare-importadesioni.pipeline.dev_resource_group_name
    allow_override = false
  }

  variable {
    name  = "NPM_CONNECTION"
    value = azuredevops_serviceendpoint_npm.pagopa-npm-bot.service_endpoint_name
  }
}

# deploy serviceendpoint authorization
resource "azuredevops_resource_authorization" "io-selfcare-importadesioni-deploy-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro, azuredevops_build_definition.io-selfcare-importadesioni-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-selfcare-importadesioni-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-selfcare-importadesioni-deploy-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw, azuredevops_build_definition.io-selfcare-importadesioni-deploy, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-selfcare-importadesioni-deploy.id
  authorized    = true
  type          = "endpoint"
}

resource "azuredevops_resource_authorization" "io-selfcare-importadesioni-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO, azuredevops_build_definition.io-selfcare-importadesioni-deploy, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-selfcare-importadesioni-deploy.id
  authorized    = true
  type          = "endpoint"
}
