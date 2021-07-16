variable "sitecorporate-portal-backend" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "corporate-site-be"
      branch_name     = "master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_deploy = true
      # common variables to all pipelines
      variables = {
        UAT_IMAGE_REPOSITORY   = "scorp-backend"
        UAT_CONTAINER_REGISTRY = "sitecorpuarc.azurecr.io"
        UAT_WEBAPP_NAME        = "sitecorp-u-portal-backend"
        UAT_IMAGE_REPOSITORY   = "scorp-backend"
        UAT_CONTAINER_REGISTRY = "sitecorpparc.azurecr.io"
        UAT_WEBAPP_NAME        = "sitecorp-p-portal-backend"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  sitecorporate-portal-backend-variables = {
    PROD_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.PROD-SITECORP.service_endpoint_name
    UAT_AZURE_SUBSCRIPTION  = azuredevops_serviceendpoint_azurerm.UAT-SITECORP.service_endpoint_name

    PROD_DOCKER_REGISTRY_SERVICE_CONNECTION = azuredevops_serviceendpoint_azurerm.scorp-azurecr-uat.service_endpoint_name
    UAT_DOCKER_REGISTRY_SERVICE_CONNECTION  = azuredevops_serviceendpoint_azurerm.scorp-azurecr-uat.service_endpoint_name
  }
  sitecorporate-portal-backend-variables_secret = {
  }
}

module "sitecorporate-portal-backend-deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.sitecorporate-portal-backend.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.sitecorporate-portal-backend.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.sitecorporate-portal-backend.pipeline.variables,
    local.sitecorporate-portal-backend-variables,
  )

  variables_secret = merge(
    var.sitecorporate-portal-backend.pipeline.variables_secret,
    local.sitecorporate-portal-backend-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurecr.scorp-azurecr-prod.id,
    azuredevops_serviceendpoint_azurecr.scorp-azurecr-uat.id,
    azuredevops_serviceendpoint_azurerm.PROD-SITECORP.id,
    azuredevops_serviceendpoint_azurerm.UAT-SITECORP.id
  ]
}
