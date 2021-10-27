locals {
  key_vault_name           = "io-p-kv-azuredevops"
  key_vault_resource_group = "io-p-rg-operations"
  key_vault_subscription   = "PROD-IO"

  selc-fe-common-variables_deploy = {
    blob_container_name = "$web"

    git_mail          = module.secrets.values["io-azure-devops-github-EMAIL"].value
    git_username      = module.secrets.values["io-azure-devops-github-USERNAME"].value
    github_connection = azuredevops_serviceendpoint_github.io-azure-devops-github-rw.service_endpoint_name

    dev_azure_subscription = azuredevops_serviceendpoint_azurerm.DEV-SELFCARE.service_endpoint_name
    dev_cdn_endpoint       = "selc-d-checkout-cdn-endpoint"
    dev_cdn_profile        = "selc-d-checkout-cdn-profile"
    dev_resource_group     = "selc-d-checkout-fe-rg"
    dev_storage_account    = "selcdcheckoutsa"

    uat_azure_subscription = azuredevops_serviceendpoint_azurerm.UAT-SELFCARE.service_endpoint_name
    uat_cdn_endpoint       = "selc-u-checkout-cdn-endpoint"
    uat_cdn_profile        = "selc-u-checkout-cdn-profile"
    uat_resource_group     = "selc-u-checkout-fe-rg"
    uat_storage_account    = "selcucheckoutsa"

    prod_azure_subscription = azuredevops_serviceendpoint_azurerm.PROD-SELFCARE.service_endpoint_name
    prod_cdn_endpoint       = "selc-p-checkout-cdn-endpoint"
    prod_cdn_profile        = "selc-p-checkout-cdn-profile"
    prod_resource_group     = "selc-p-checkout-fe-rg"
    prod_storage_account    = "selcpcheckoutsa"

    dev_react_app_url_fe_login                 = "https://dev.selfcare.pagopa.it/auth"
    dev_react_app_url_fe_onboarding            = "https://dev.selfcare.pagopa.it/onboarding"
    dev_react_app_url_fe_dashboard             = "https://dev.selfcare.pagopa.it/dashboard"
    dev_react_app_url_api_login                = "https://api.dev.selfcare.pagopa.it/spid/v1"
    dev_react_app_url_api_party_process        = "https://api.dev.selfcare.pagopa.it/party-process/v1"
    dev_react_app_url_api_party_management     = "https://api.dev.selfcare.pagopa.it/party-management/v1"
    dev_react_app_url_api_party_registry_proxy = "https://api.dev.selfcare.pagopa.it/party-registry-proxy/v1"
    dev_react_app_url_api_dashboard            = "https://api.dev.selfcare.pagopa.it/dashboard/v1"

    uat_react_app_url_fe_login                 = "https://uat.selfcare.pagopa.it/auth"
    uat_react_app_url_fe_onboarding            = "https://uat.selfcare.pagopa.it/onboarding"
    uat_react_app_url_fe_dashboard             = "https://uat.selfcare.pagopa.it/dashboard"
    uat_react_app_url_api_login                = "https://api.uat.selfcare.pagopa.it/spid/v1"
    uat_react_app_url_api_party_process        = "https://api.uat.selfcare.pagopa.it/party-process/v1"
    uat_react_app_url_api_party_management     = "https://api.uat.selfcare.pagopa.it/party-management/v1"
    uat_react_app_url_api_party_registry_proxy = "https://api.uat.selfcare.pagopa.it/party-registry-proxy/v1"
    uat_react_app_url_api_dashboard            = "https://api.uat.selfcare.pagopa.it/dashboard/v1"

    prod_react_app_url_fe_login                 = "https://selfcare.pagopa.it/auth"
    prod_react_app_url_fe_onboarding            = "https://selfcare.pagopa.it/onboarding"
    prod_react_app_url_fe_dashboard             = "https://selfcare.pagopa.it/dashboard"
    prod_react_app_url_api_login                = "https://api.selfcare.pagopa.it/spid/v1"
    prod_react_app_url_api_party_process        = "https://api.selfcare.pagopa.it/party-process/v1"
    prod_react_app_url_api_party_management     = "https://api.selfcare.pagopa.it/party-management/v1"
    prod_react_app_url_api_party_registry_proxy = "https://api.selfcare.pagopa.it/party-registry-proxy/v1"
    prod_react_app_url_api_dashboard            = "https://api.selfcare.pagopa.it/dashboard/v1"
  }
}