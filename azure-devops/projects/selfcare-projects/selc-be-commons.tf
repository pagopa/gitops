variable "selc-be-commons" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "selfcare-commons"
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
  selc-be-commons-variables = {
    settings_xml_rw_secure_file_name = "settings-rw.xml"
    settings_xml_ro_secure_file_name = "settings-ro.xml"
    maven_remote_repo_server_id      = "selc"
    maven_remote_repo                = "https://pkgs.dev.azure.com/pagopaspa/selfcare-projects/_packaging/selfcare/maven/v1"
  }
  # global secrets
  selc-be-commons-variables_secret = {

  }
  # code_review vars
  selc-be-commons-variables_code_review = {
    sonarcloud_service_conn = "SONARCLOUD-SERVICE-CONN"
    sonarcloud_org          = var.selc-be-commons.repository.organization
    sonarcloud_project_key  = "${var.selc-be-commons.repository.organization}_${var.selc-be-commons.repository.name}"
    sonarcloud_project_name = var.selc-be-commons.repository.name
  }
  # code_review secrets
  selc-be-commons-variables_secret_code_review = {

  }
  # deploy vars
  selc-be-commons-variables_deploy = {

  }
  # deploy secrets
  selc-be-commons-variables_secret_deploy = {

  }
}

module "selc-be-commons_code_review" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_code_review?ref=v1.0.0"
  count  = var.selc-be-commons.pipeline.enable_code_review == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-be-commons.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  pull_request_trigger_use_yaml = true

  variables = merge(
    local.selc-be-commons-variables,
    local.selc-be-commons-variables_code_review,
  )

  variables_secret = merge(
    local.selc-be-commons-variables_secret,
    local.selc-be-commons-variables_secret_code_review,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
    local.azuredevops_serviceendpoint_sonarcloud_id,
  ]
}

module "selc-be-commons_deploy" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v1.0.0"
  count  = var.selc-be-commons.pipeline.enable_deploy == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.selc-be-commons.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id

  ci_trigger_use_yaml = true

  variables = merge(
    local.selc-be-commons-variables,
    local.selc-be-commons-variables_deploy,
  )

  variables_secret = merge(
    local.selc-be-commons-variables_secret,
    local.selc-be-commons-variables_secret_deploy,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id,
  ]
}
