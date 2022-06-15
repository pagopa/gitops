module "apim_backup" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.4.0"

  project_id                   = azuredevops_project.project.id
  repository                   = var.apim_backup.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  path                         = "backups"
  pipeline_name                = "backup-apim"

  ci_trigger_use_yaml = false

  variables = {
    apim_name            = "io-p-apim-api"
    storage_account_name = "apimbackup"
    backup_key           = "apimbackup/apim-backup"
  }

  variables_secret = {}

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
  ]

  schedules = {
    days_to_build              = ["Sat"]
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