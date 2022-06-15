variable "iac" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-infra"
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

variable "apim_backup" {
  default = {
    repository = {
      organization    = "pagopa"
      name            = "io-infra"
      branch_name     = "main"
      pipelines_path  = ".devops"
      yml_prefix_name = "backupa-apim"
    }
    pipeline = {
      enable_code_review = false
      enable_deploy      = false
    }
  }
}