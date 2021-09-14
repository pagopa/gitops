variable "tlscert-testcert-cstar-dev-pagopa-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "acme-tiny"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_tls_cert = true
      path            = "TLS-Certificates"
      name            = "testcert.dev.cstar.pagopa.it"
      # common variables to all pipelines
      variables = {
        CERT_NAME_EXPIRE_SECONDS = "2592000" #30 days
        KEY_VAULT_NAME           = "cstar-d-kv"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  tlscert-testcert-cstar-dev-pagopa-it-variables = {
    KEY_VAULT_CERT_NAME          = replace(var.tlscert-testcert-cstar-dev-pagopa-it.pipeline.name, ".", "-")
    KEY_VAULT_SERVICE_CONNECTION = azuredevops_serviceendpoint_azurerm.DEV-CSTAR.service_endpoint_name
  }
  tlscert-testcert-cstar-dev-pagopa-it-variables_secret = {
  }
}

module "tlscert-testcert-cstar-dev-pagopa-it-cert_az" {
  # source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_certaz?ref=v0.0.2"
  source = "/Users/pasqualedevita/Documents/github/azuredevops-tf-modules/azuredevops_build_definition_tls_cert"
  count  = var.tlscert-testcert-cstar-dev-pagopa-it.pipeline.enable_tls_cert == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.tlscert-testcert-cstar-dev-pagopa-it.repository
  name                         = var.tlscert-testcert-cstar-dev-pagopa-it.pipeline.name
  path                         = var.tlscert-testcert-cstar-dev-pagopa-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id

  variables = merge(
    var.tlscert-testcert-cstar-dev-pagopa-it.pipeline.variables,
    local.tlscert-testcert-cstar-dev-pagopa-it-variables,
  )

  variables_secret = merge(
    var.tlscert-testcert-cstar-dev-pagopa-it.pipeline.variables_secret,
    local.tlscert-testcert-cstar-dev-pagopa-it-variables_secret,
  )

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_azurerm.DEV-CSTAR.id,
  ]
}
