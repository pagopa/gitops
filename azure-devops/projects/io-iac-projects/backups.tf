module "apim_backup" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.4.0"

  project_id                   = azuredevops_project.project.id
  repository                   = var.apim_backup.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  path                         = "backups"
  pipeline_name                = "backup-apim"

  ci_trigger_use_yaml = false

  variables = {
    apim_name                 = "io-p-apim-api"
    apim_rg                   = "io-p-rg-internal"
    storage_account_name      = "iopstbackups"
    backup_name               = "apim-backup"
    storage_account_container = "apimbackup"
    storage_account_rg        = "io-p-rg-operations"
  }

  variables_secret = {}

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_azurerm.PROD-IO.id,
  ]

  schedules = {
    days_to_build              = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    schedule_only_with_changes = false
    start_hours                = 5
    start_minutes              = 0
    time_zone                  = "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"
    branch_filter = {
      include = ["main"]
      exclude = []
    }
  }
}