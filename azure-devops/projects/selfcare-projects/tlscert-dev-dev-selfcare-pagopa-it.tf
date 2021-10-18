variable "tlscert-dev-dev-selfcare-pagopa-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "le-azure-acme-tiny"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_tls_cert         = true
      path                    = "TLS-Certificates\\DEV"
      dns_record_name         = ""
      dns_zone_name           = "dev.selfcare.pagopa.it"
      dns_zone_resource_group = "selc-d-vnet-rg"
      # common variables to all pipelines
      variables = {
        CERT_NAME_EXPIRE_SECONDS = "2592000" #30 days
        KEY_VAULT_NAME           = "selc-d-kv"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  tlscert-dev-dev-selfcare-pagopa-it = {
    tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
    subscription_name = "DEV-SelfCare"
    subscription_id   = module.secrets.values["PAGOPAIT-DEV-SELFCARE-SUBSCRIPTION-ID"].value
  }
  tlscert-dev-dev-selfcare-pagopa-it-variables = {
    KEY_VAULT_CERT_NAME          = "${replace(var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_record_name, ".", "-")}-${replace(var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_zone_name, ".", "-")}"
    KEY_VAULT_SERVICE_CONNECTION = module.DEV-SELFCARE-TLS-CERT-SERVICE-CONN.service_endpoint_name
  }
  tlscert-dev-dev-selfcare-pagopa-it-variables_secret = {
  }
}

module "tlscert-dev-dev-selfcare-pagopa-it-cert_az" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert?ref=v1.1.0"
  count  = var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.enable_tls_cert == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.tlscert-dev-dev-selfcare-pagopa-it.repository
  name                         = "${var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_record_name}.${var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_zone_name}"
  path                         = var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id

  dns_record_name         = var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_record_name
  dns_zone_name           = var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_zone_name
  dns_zone_resource_group = var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.dns_zone_resource_group
  tenant_id               = local.tlscert-dev-dev-selfcare-pagopa-it.tenant_id
  subscription_name       = local.tlscert-dev-dev-selfcare-pagopa-it.subscription_name
  subscription_id         = local.tlscert-dev-dev-selfcare-pagopa-it.subscription_id

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group

  variables = merge(
    var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.variables,
    local.tlscert-dev-dev-selfcare-pagopa-it-variables,
  )

  variables_secret = merge(
    var.tlscert-dev-dev-selfcare-pagopa-it.pipeline.variables_secret,
    local.tlscert-dev-dev-selfcare-pagopa-it-variables_secret,
  )

  service_connection_ids_authorization = [
    module.DEV-SELFCARE-TLS-CERT-SERVICE-CONN.service_endpoint_id,
  ]
}