locals {
  key_vault_name           = "io-p-kv-azuredevops"
  key_vault_resource_group = "io-p-rg-operations"
  key_vault_subscription   = "PROD-IO"
}

variable "apim_backup" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "cstar-infrastructure"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = "backup-apim"
    }
    pipeline = {
      enable_code_review = true
      enable_deploy      = true
      path               = "cstar-infrastructure"
    }
  }
}