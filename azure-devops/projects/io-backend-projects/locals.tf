locals {
  prefix                   = "io"
  key_vault_name           = "io-p-kv-azuredevops"
  key_vault_resource_group = "io-p-rg-operations"
  key_vault_subscription   = "PROD-IO"
  agent_pool               = "io-prod-linux"
  #tfsec:ignore:GEN002
  tlscert_renew_token = "v1"
}
