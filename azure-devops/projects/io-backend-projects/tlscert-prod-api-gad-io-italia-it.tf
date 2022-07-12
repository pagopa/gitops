variable "tlscert-prod-api-gad-io-italia-it" {
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
      dns_record_name         = "api-gad"
      dns_zone_name           = "io.italia.it"
      dns_zone_resource_group = "io-p-rg-external"
      # common variables to all pipelines
      variables = {
        CERT_NAME_EXPIRE_SECONDS = "2592000" #30 days
        KEY_VAULT_NAME           = "io-p-kv-common"
      }
      # common secret variables to all pipelines
      variables_secret = {
      }
    }
  }
}

locals {
  tlscert-prod-api-gad-io-italia-it = {
    tenant_id         = module.secrets.values["PAGOPAIT-TENANTID"].value
    subscription_id   = module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
    subscription_name = "PROD-IO"
  }
  tlscert-prod-api-gad-io-italia-it-variables = {
    KEY_VAULT_SERVICE_CONNECTION = module.PROD-IO-TLS-CERT-SERVICE-CONN.service_endpoint_name
  }
  tlscert-prod-api-gad-io-italia-it-variables_secret = {
  }
}

module "tlscert-prod-api-gad-io-italia-it-cert_az" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_tls_cert?ref=v2.1.0"
  count  = var.tlscert-prod-api-gad-io-italia-it.pipeline.enable_tls_cert == true ? 1 : 0

  project_id = azuredevops_project.project.id
  repository = var.tlscert-prod-api-gad-io-italia-it.repository
  name       = "${var.tlscert-prod-api-gad-io-italia-it.pipeline.dns_record_name}.${var.tlscert-prod-api-gad-io-italia-it.pipeline.dns_zone_name}"
  #tfsec:ignore:GEN003
  renew_token                  = local.tlscert_renew_token
  path                         = var.tlscert-prod-api-gad-io-italia-it.pipeline.path
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-ro.id

  dns_record_name         = var.tlscert-prod-api-gad-io-italia-it.pipeline.dns_record_name
  dns_zone_name           = var.tlscert-prod-api-gad-io-italia-it.pipeline.dns_zone_name
  dns_zone_resource_group = var.tlscert-prod-api-gad-io-italia-it.pipeline.dns_zone_resource_group
  tenant_id               = local.tlscert-prod-api-gad-io-italia-it.tenant_id
  subscription_name       = local.tlscert-prod-api-gad-io-italia-it.subscription_name
  subscription_id         = local.tlscert-prod-api-gad-io-italia-it.subscription_id

  credential_subcription              = local.key_vault_subscription
  credential_key_vault_name           = local.key_vault_name
  credential_key_vault_resource_group = local.key_vault_resource_group

  variables = merge(
    var.tlscert-prod-api-gad-io-italia-it.pipeline.variables,
    local.tlscert-prod-api-gad-io-italia-it-variables,
  )

  variables_secret = merge(
    var.tlscert-prod-api-gad-io-italia-it.pipeline.variables_secret,
    local.tlscert-prod-api-gad-io-italia-it-variables_secret,
  )

  service_connection_ids_authorization = [
    module.PROD-IO-TLS-CERT-SERVICE-CONN.service_endpoint_id,
  ]
}
