module "secrets" {
  source = "../../modules/secrets/"

  resource_group = "io-p-rg-operations"
  keyvault_name  = "io-p-kv-azuredevops"

  secrets = [
    "io-azure-devops-github-ro-TOKEN",
    "io-azure-devops-github-pr-TOKEN",
    "PAGOPAIT-TENANTID",
    "PAGOPAIT-DEV-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-UAT-CSTAR-SUBSCRIPTION-ID",
    "PAGOPAIT-PROD-CSTAR-SUBSCRIPTION-ID",
    "cstar-aks-dev-apiserver-url",
    "cstar-aks-dev-kubeconfig",
    # "cstar-aks-uat-apiserver-url",
    # "cstar-aks-uat-kubeconfig",
    # "cstar-aks-prod-apiserver-url",
    # "cstar-aks-prod-kubeconfig",
  ]
}
