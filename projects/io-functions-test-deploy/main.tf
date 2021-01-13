terraform {
  backend "azurerm" {
    resource_group_name  = "dev-pasquale"
    storage_account_name = "devpasqualesa"
    container_name       = "tfstateazuredevops"
    key                  = "io-functions-test-deploy.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "0.1.1"
    }
  }
}

# https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs

provider "azurerm" {
  version = "~> 2.42.0"
  features {}
}

provider "azuredevops" {
  # Configuration options
  version = "0.1.1"
}

resource "azuredevops_project" "project" {
  name               = "io-functions-test-deploy"
  description        = "This is the DevOps project named after pagopa/io-functions-test-deploy GitHub repository and it is used for test only."
  visibility         = "public"
  version_control    = "Git"
  work_item_template = "Basic"
}

# Github App
resource "azuredevops_serviceendpoint_github" "pagopa" {
  project_id            = azuredevops_project.project.id
  service_endpoint_name = "pagopa"
  # description           = null
  lifecycle {
    ignore_changes = [description]
  }
}

resource "azuredevops_build_definition" "build" {
  project_id = azuredevops_project.project.id
  name       = "${azuredevops_project.project.name}.test"
  path       = "\\testfolder"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "GitHub"
    repo_id     = "pagopa/io-azure-devops"
    branch_name = "main"
    yml_path    = ".devops/test-azure-pipelines.yml"
    service_connection_id = azuredevops_serviceendpoint_github.pagopa.id
  }

  variable {
    name  = "PipelineVariable"
    value = "Go Microsoft!"
  }

  variable {
    name         = "PipelineSecret"
    secret_value = "ZGV2cw"
    is_secret    = true
  }
}

