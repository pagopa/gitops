variable "corporate-site-be" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "corporate-site-be"
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
  corporate-site-be-variables = {

  }
  # global secrets
  corporate-site-be-variables_secret = {

  }
  # code_review vars
  corporate-site-be-variables_code_review = {

  }
  # code_review secrets
  corporate-site-be-variables_secret_code_review = {

  }
  # deploy vars
  corporate-site-be-variables_deploy = {
    uat_image_repository                    = "scorp-backend"
    uat_container_registry                  = "scorpuarc.azurecr.io"
    uat_webapp_name                         = "scorp-u-portal-backend"
    uar_agent_pool                          = "scorp-uat-linux"
    uat_azure_subscription                  = azuredevops_serviceendpoint_azurerm.UAT-SITECORP.service_endpoint_name
    uat_docker_registry_service_connection  = azuredevops_serviceendpoint_azurecr.scorp-azurecr-uat.service_endpoint_name
    prod_webapp_name                        = "scorp-p-portal-backend"
    prod_image_repository                   = "scorp-backend"
    prod_container_registry                 = "scorpparc.azurecr.io"
    prod_agent_pool                         = "scorp-prod-linux"
    prod_azure_subscription                 = azuredevops_serviceendpoint_azurerm.PROD-SITECORP.service_endpoint_name
    prod_docker_registry_service_connection = azuredevops_serviceendpoint_azurecr.scorp-azurecr-uat.service_endpoint_name
  }
  # deploy secrets
  corporate-site-be-variables_secret_deploy = {

  }
}

module "corporate-site-be-deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v0.0.3"
  count  = var.corporate-site-be.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.corporate-site-be.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    local.corporate-site-be-variables,
    local.corporate-site-be-variables_deploy,
  )

  variables_secret = merge(
    local.corporate-site-be-variables_secret,
    local.corporate-site-be-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    # azuredevops_serviceendpoint_azurecr.scorp-azurecr-prod.id,
    azuredevops_serviceendpoint_azurecr.scorp-azurecr-uat.id,
    azuredevops_serviceendpoint_azurerm.PROD-SITECORP.id,
    azuredevops_serviceendpoint_azurerm.UAT-SITECORP.id,
  ]
}
