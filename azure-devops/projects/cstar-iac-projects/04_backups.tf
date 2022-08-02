module "apim_backup" {
  source = "git::https://github.com/pagopa/azuredevops-tf-modules.git//azuredevops_build_definition_deploy?ref=v2.4.0"

  project_id                   = azuredevops_project.project.id
  repository                   = var.apim_backup.repository
  github_service_connection_id = azuredevops_serviceendpoint_github.io-azure-devops-github-pr.id
  path                         = "backups"
  pipeline_name                = "backup-apim"

  ci_trigger_use_yaml = false

  variables = {
    apim_name                 = "cstar-p-apim"
    apim_rg                   = "cstar-p-api-rg"
    storage_account_name      = "cstarpbackupstorage"
    backup_name               = "apim-backup"
    storage_account_container = "apim"
    storage_account_rg        = "cstar-p-storage-rg"
  }

  variables_secret = {}

  service_connection_ids_authorization = [
    azuredevops_serviceendpoint_azurerm.PROD-CSTAR.id,
  ]

  schedules = {
    days_to_build              = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    schedule_only_with_changes = false
    start_hours                = 5
    start_minutes              = 30
    time_zone                  = "(UTC+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"
    branch_filter = {
      include = ["main"]
      exclude = []
    }
  }
}