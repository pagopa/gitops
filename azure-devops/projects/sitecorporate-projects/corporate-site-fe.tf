variable "corporate-site-fe" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "corporate-site-fe"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_deploy = true
    }
  }
}

locals {
  # global vars
  corporate-site-fe-variables = {

  }
  # global secrets
  corporate-site-fe-variables_secret = {

  }
  # code_review vars
  corporate-site-fe-variables_code_review = {

  }
  # code_review secrets
  corporate-site-fe-variables_secret_code_review = {

  }
  # deploy vars
  corporate-site-fe-variables_deploy = {
    prod_storage_account_name = "scorppsaws"
    prod_profile_cdn_name     = "scorp-p-cdn-common"
    prod_endpoint_name        = "scorp-p-cdnendpoint-frontend"
    prod_resource_group_name  = "scorp-p-public-rg"
    prod_frontend_base_url    = "https://www.pagopa.it"
    prod_azure_subscription   = azuredevops_serviceendpoint_azurerm.PROD-SITECORP.service_endpoint_name
    uat_storage_account_name  = "scorpusaws"
    uat_profile_cdn_name      = "scorp-u-cdn-common"
    uat_endpoint_name         = "scorp-u-cdnendpoint-frontend"
    uat_resource_group_name   = "scorp-u-public-rg"
    uat_frontend_base_url     = "https://www.uat.sitecorporate.pagopa.it"
    uat_azure_subscription    = azuredevops_serviceendpoint_azurerm.UAT-SITECORP.service_endpoint_name
  }
  # deploy secrets
  corporate-site-fe-variables_secret_deploy = {
    uat_backend_base_url   = module.secrets.values["sitecorp-u-backend-base-url"].value
    uat_frontend_password  = module.secrets.values["sitecorp-u-frontend-password"].value
    prod_backend_base_url  = module.secrets.values["sitecorp-p-backend-base-url"].value
    prod_frontend_password = module.secrets.values["sitecorp-p-frontend-password"].value
  }
}

module "corporate-site-fe-deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.corporate-site-fe.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.corporate-site-fe.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.corporate-site-fe-variables,
    local.corporate-site-fe-variables_deploy,
  )

  variables_secret = merge(
    local.corporate-site-fe-variables_secret,
    local.corporate-site-fe-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    azuredevops_serviceendpoint_azurerm.PROD-SITECORP.id,
    azuredevops_serviceendpoint_azurerm.UAT-SITECORP.id,
  ]
}
