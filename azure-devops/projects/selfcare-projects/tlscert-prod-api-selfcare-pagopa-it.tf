variable "tlscert-prod-api-selfcare-pagopa-it" {
  default = {
    repository = {
      organization   = "pagopa"
      name           = "le-azure-acme-tiny"
      branch_name    = "master"
      pipelines_path = "."
    }
    pipeline = {
      enable_tls_cert         = true
      path                    = "TLS-Certificates\\PROD"
      dns_record_name         = "api"
      dns_zone_name           = "selfcare.pagopa.it"
      dns_zone_resource_group = "selc-p-vnet-rg"
      # common variables to all pipelines
      variables = {
        CERT_NAME_EXPIRE_SECONDS = "2592000" #30 days
        KEY_VAULT_NAME           = "selc-p-kv"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  tlscert-prod-api-selfcare-pagopa-it = {
    tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
    subscription_name = "PROD-SelfCare"
    subscription_id   = module.secrets.values["PAGOPAIT-PROD-SELFCARE-SUBSCRIPTION-ID"].value
  }
  tlscert-prod-api-selfcare-pagopa-it-variables = {
    KEY_VAULT_CERT_NAME          = "${replace(var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_record_name, ".", "-")}-${replace(var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_zone_name, ".", "-")}"
    KEY_VAULT_SERVICE_CONNECTION = module.PROD-SELFCARE-TLS-CERT-SERVICE-CONN.service_endpoint_name
  }
  tlscert-prod-api-selfcare-pagopa-it-variables_secret = {
  }
}

module "tlscert-prod-api-selfcare-pagopa-it-cert_az" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert?ref=v2.0.4"
  count  = var.tlscert-prod-api-selfcare-pagopa-it.pipeline.enable_tls_cert == true ? 1 : 0

  project_id                   = azuredevops_project.project.id
  repository                   = var.tlscert-prod-api-selfcare-pagopa-it.repository
  name                         = "${var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_record_name}.${var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_zone_name}"
  path                         = var.tlscert-prod-api-selfcare-pagopa-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id
  #tfsec:ignore:GEN003
  renew_token = local.tlscert_renew_token

  dns_record_name         = var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_record_name
  dns_zone_name           = var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_zone_name
  dns_zone_resource_group = var.tlscert-prod-api-selfcare-pagopa-it.pipeline.dns_zone_resource_group
  tenant_id               = local.tlscert-prod-api-selfcare-pagopa-it.tenant_id
  subscription_name       = local.tlscert-prod-api-selfcare-pagopa-it.subscription_name
  subscription_id         = local.tlscert-prod-api-selfcare-pagopa-it.subscription_id

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group

  variables = merge(
    var.tlscert-prod-api-selfcare-pagopa-it.pipeline.variables,
    local.tlscert-prod-api-selfcare-pagopa-it-variables,
  )

  variables_secret = merge(
    var.tlscert-prod-api-selfcare-pagopa-it.pipeline.variables_secret,
    local.tlscert-prod-api-selfcare-pagopa-it-variables_secret,
  )

  service_connection_ids_authorization = [
    module.PROD-SELFCARE-TLS-CERT-SERVICE-CONN.service_endpoint_id,
  ]


  schedules = {
    days_to_build              = ["Fri"]
    schedule_only_with_changes = false
    start_hours                = 5
    start_minutes              = 0
    time_zone                  = "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"
    branch_filter = {
      include = ["master"]
      exclude = []
    }
  }
}
