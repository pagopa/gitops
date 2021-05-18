variable "io-italia-it" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io.italia.it"
      branch_name     = "master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_deploy = true
      # common variables to all pipelines
      variables = {
        BLOB_CONTAINER_NAME       = "$web"
        DEV_STORAGE_ACCOUNT_NAME  = "NA"
        DEV_PROFILE_CDN_NAME      = "NA"
        DEV_ENDPOINT_NAME         = "NA"
        DEV_RESOURCE_GROUP_NAME   = "NA"
        PROD_STORAGE_ACCOUNT_NAME = "iopstcdniosite"
        PROD_PROFILE_CDN_NAME     = "io-p-cdn-common"
        PROD_ENDPOINT_NAME        = "io-p-cdnendpoint-iosite"
        PROD_RESOURCE_GROUP_NAME  = "io-p-rg-common"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  io-italia-it-variables = {
    PROD_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.PROD-IO.service_endpoint_name
    DEV_AZURE_SUBSCRIPTION  = azuredevops_serviceendpoint_azurerm.DEV-IO.service_endpoint_name
  }
  io-italia-it-variables_secret = {
  }
}

module "io-italia-it-deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.io-italia-it.pipeline.enable_deploy == true ? 1 : 0

  project_id = azuredevops_project.project.id
  repository = var.io-italia-it.repository
  # name                         = var.io-italia-it.pipeline.name
  # path                         = var.io-italia-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.io-italia-it.pipeline.variables,
    local.io-italia-it-variables,
  )

  variables_secret = merge(
    var.io-italia-it.pipeline.variables_secret,
    local.io-italia-it-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
    azuredevops_serviceendpoint_azurerm.DEV-IO.id,
  ]
}
