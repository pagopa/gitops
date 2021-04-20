variable "io-services-metadata" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "io-services-metadata"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      cache_version_id = "v3"
    }
  }
}

# Define code azure pipeline
resource "azuredevops_build_definition" "io-services-metadata" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr, azuredevops_project.project]

  project_id = azuredevops_project.project.id
  name       = format("%s.azure-pipeline", var.io-services-metadata.repository.name)
  path       = format("\\%s", var.io-services-metadata.repository.name)

  pull_request_trigger {
    initial_branch = var.io-services-metadata.repository.branch_name
    forks {
      enabled       = false
      share_secrets = false
    }
    override {
      auto_cancel = false
      branch_filter {
        include = [var.io-services-metadata.repository.branch_name]
      }
      path_filter {
        exclude = []
        include = []
      }
    }
  }

  repository {
    repo_type = "GitHub"
    repo_id = join("/", [
      var.io-services-metadata.repository.organization,
      var.io-services-metadata.repository.name,
    ])
    branch_name = var.io-services-metadata.repository.branch_name
    yml_path = join("/", [
      var.io-services-metadata.repository.pipelines_path,
      "azure-pipelines.yml",
    ])
    service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  }

  variable {
    name  = "ENABLE_DATA_COPY"
    value = "true"
  }

  variable {
    name  = "PRODUCTION_AZURE_SUBSCRIPTION"
    value = "PROD-IO-SERVICE-CONN"
  }

  variable {
    name  = "PRODUCTION_STORAGE_ACCOUNT_NAME"
    value = "iopstcdnassets"
  }

  variable {
    name  = "TEST_AZURE_SUBSCRIPTION"
    value = "DEV-IO-SERVICE-CONN"
  }

  variable {
    name  = "TEST_STORAGE_ACCOUNT_NAME"
    value = "deviostcdnassets"
  }

}

# Allow pipeline to access Github readonly service connection, needed to access external templates to be used inside the pipeline
resource "azuredevops_resource_authorization" "io-services-metadata-github-ro-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-ro,
    azuredevops_build_definition.io-services-metadata,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  definition_id = azuredevops_build_definition.io-services-metadata.id
  authorized    = true
  type          = "endpoint"
}

# Allow code pipeline to access Github pr service connection, needed to checkout code from the pull request branch
resource "azuredevops_resource_authorization" "io-services-metadata-github-pr-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-pr,
    azuredevops_build_definition.io-services-metadata,
    azuredevops_project.project
  ]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  definition_id = azuredevops_build_definition.io-services-metadata.id
  authorized    = true
  type          = "endpoint"
}

# Allow pipeline to access Azure PROD-IO subscription service connection, needed to interact with Azure resources
resource "azuredevops_resource_authorization" "io-functions-public-deploy-azurerm-PROD-IO-auth" {
  depends_on = [azuredevops_serviceendpoint_azurerm.PROD-IO,
  azuredevops_build_definition.io-services-metadata, time_sleep.wait]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_azurerm.PROD-IO.id
  definition_id = azuredevops_build_definition.io-services-metadata.id
  authorized    = true
  type          = "endpoint"
}

# Allow deploy pipeline to access Github writable service connection, needed to bump project version and publish a new relase
resource "azuredevops_resource_authorization" "io-services-metadata-github-rw-auth" {
  depends_on = [azuredevops_serviceendpoint_github.io-azure-devops-github-rw,
  azuredevops_build_definition.io-services-metadata, azuredevops_project.project]

  project_id    = azuredevops_project.project.id
  resource_id   = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.id
  definition_id = azuredevops_build_definition.io-services-metadata.id
  authorized    = true
  type          = "endpoint"
}
