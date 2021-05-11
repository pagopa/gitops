variable "template-pipeline" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "template-pipeline"
      branch_name    = "master"
      pipelines_path = ".devops"
    }
    pipeline = {
      enable_code_review     = false
      enable_deploy          = false
      enable_azure_pipelines = false
      # common variables to all pipelines
      variables = {
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
      code_review_variables = {
      }
      code_review_variables_secret = {
      }
      deploy_variables = {
        #common env
        #use dev prefix
        #use uat prefix
        #use prod prefix
      }
      deploy_variables_secret = {
        #common env
        #use dev prefix
        #use uat prefix
        #use prod prefix
      }
    }
  }
}

module "template-pipeline-code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=add-codereview-pipeline-module"
  count  = var.template-pipeline.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.template-pipeline.pipeline.variables,
    var.template-pipeline.pipeline.code_review_variables,
  )

  variables_secret = merge(
    var.template-pipeline.pipeline.variables_secret,
    var.template-pipeline.pipeline.code_review_variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    # TODO azure devops terraform provider does not support SonarCloud service endpoint
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "template-pipeline-deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=add-deploy-pipeline-module"
  count  = var.template-pipeline.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.template-pipeline.pipeline.variables,
    var.template-pipeline.pipeline.deploy_variables,
  )

  variables_secret = merge(
    var.template-pipeline.pipeline.variables_secret,
    var.template-pipeline.pipeline.deploy_variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-uat.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-prod.id,
    # azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.id,
    # azuredevops_serviceendpoint_kubernetes.cstar-aks-uat.id,
    # azuredevops_serviceendpoint_kubernetes.cstar-aks-prod.id,
  ]
}

module "template-pipeline-azure_pipelines" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_azure_pipelines_cstar?ref=add-azurepipelinescstar-pipeline-module"
  count  = var.template-pipeline.pipeline.enable_azure_pipelines == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.template-pipeline.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  variables = merge(
    var.template-pipeline.pipeline.variables,
  )

  variables_secret = merge(
    var.template-pipeline.pipeline.variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-dev.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-uat.id,
    # azuredevops_serviceendpoint_azurecr.cstar-azurecr-prod.id,
    # azuredevops_serviceendpoint_kubernetes.cstar-aks-dev.id,
    # azuredevops_serviceendpoint_kubernetes.cstar-aks-uat.id,
    # azuredevops_serviceendpoint_kubernetes.cstar-aks-prod.id,
  ]
}
