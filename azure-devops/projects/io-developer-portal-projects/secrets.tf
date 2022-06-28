module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "DANGER-GITHUB-API-TOKEN",
    "DANGER-JIRA-USERNAME",
    "DANGER-JIRA-PASSWORD",
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-rw-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "io-azure-devops-github-EMAIL",
    "io-azure-devops-github-USERNAME",
    "PAGOPAIT-PROD-IO-SUBSCRIPTION-ID",
    "PAGOPAIT-DEV-IO-SUBSCRIPTION-ID",
    "PAGOPAIT-TENANTID",
    "pagopa-npm-bot-TOKEN",
  ]
}
