variable "sitecorporate-portal-frontend" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "corporate-site-fe"
      branch_name     = "master"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_deploy = true
      # common variables to all pipelines
      variables = {
        UAT_STORAGE_ACCOUNT_NAME = "sitecorpusaws"
        UAT_PROFILE_CDN_NAME     = "sitecorp-u-cdn-common"
        UAT_ENDPOINT_NAME        = "sitecorp-u-cdnendpoint-frontend"
        UAT_RESOURCE_GROUP_NAME  = "sitecorp-u-public-rg"
        UAT_STORAGE_ACCOUNT_NAME = "sitecorppsaws"
        UAT_PROFILE_CDN_NAME     = "sitecorp-p-cdn-common"
        UAT_ENDPOINT_NAME        = "sitecorp-p-cdnendpoint-frontend"
        UAT_RESOURCE_GROUP_NAME  = "sitecorp-p-public-rg"
        UAT_FRONTEND_BASE_URL    = ""
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  sitecorporate-portal-frontend-variables = {
    PROD_AZURE_SUBSCRIPTION = azuredevops_serviceendpoint_azurerm.PROD-SITECORP.service_endpoint_name

    UAT_AZURE_SUBSCRIPTION  = azuredevops_serviceendpoint_azurerm.UAT-SITECORP.service_endpoint_name
    UAT_BACKEND_BASE_URL    = data.azurerm_key_vault_secret.key_vault_secret["sitecorp-u-backend-base-url"].value
    UAT_FRONTEND_PASSWORD   = data.azurerm_key_vault_secret.key_vault_secret["sitecorp-u-frontend-password"].value
  }
  sitecorporate-portal-frontend-variables_secret = {
  }
}

module "sitecorporate-portal-frontend-deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.sitecorporate-portal-frontend.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.sitecorporate-portal-frontend.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.sitecorporate-portal-frontend.pipeline.variables,
    local.sitecorporate-portal-frontend-variables,
  )

  variables_secret = merge(
    var.sitecorporate-portal-frontend.pipeline.variables_secret,
    local.sitecorporate-portal-frontend-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-SITECORP.id,
    azuredevops_serviceendpoint_azurerm.UAT-SITECORP.id,
  ]
}
