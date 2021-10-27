variable "selc-be-starter-parent" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-starter-parent"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = null
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
    }
  }
}

locals {
  # global vars
  selc-be-starter-parent-variables = {

  }
  # global secrets
  selc-be-starter-parent-variables_secret = {

  }
  # code_review vars
  selc-be-starter-parent-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.selc-be-starter-parent.repository.organization
    sonarcloud_project_key  = "${var.selc-be-starter-parent.repository.organization}_${var.selc-be-starter-parent.repository.name}"
    sonarcloud_project_name = var.selc-be-starter-parent.repository.name
  }
  # code_review secrets
  selc-be-starter-parent-variables_secret_code_review = {

  }
  # deploy vars
  selc-be-starter-parent-variables_deploy = {
    settings_xml_rw_secure_file_name = "settings-rw.xml"
    maven_alternate_deploy_repo      = "selc::https://pkgs.dev.azure.com/pagopaspa/selfcare-projects/_packaging/selfcare/maven/v1"
  }
  # deploy secrets
  selc-be-starter-parent-variables_secret_deploy = {

  }
}

module "selc-be-starter-parent_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.selc-be-starter-parent.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-be-starter-parent.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-be-starter-parent-variables,
    local.selc-be-starter-parent-variables_code_review,
  )

  variables_secret = merge(
    local.selc-be-starter-parent-variables_secret,
    local.selc-be-starter-parent-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "selc-be-starter-parent_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.selc-be-starter-parent.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-be-starter-parent.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-be-starter-parent-variables,
    local.selc-be-starter-parent-variables_deploy,
  )

  variables_secret = merge(
    local.selc-be-starter-parent-variables_secret,
    local.selc-be-starter-parent-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}
