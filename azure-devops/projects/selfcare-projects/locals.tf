locals {
  key_vault_name           = "io-p-kv-azuredevops"
  key_vault_resource_group = "io-p-rg-operations"
  key_vault_subscription   = "PROD-IO"
  #tfsec:ignore:GEN002
  tlscert_renew_token = "v1"

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
    dev_analytics_enabled  = "true"
    dev_analytics_mocked   = "false"
    dev_mixpanel_token     = "6e1290bdda5885981a2f443f37444f0f"
    dev_onetrust_domain_id = "a8f58d7a-7f6a-4fe6-ac02-f95bac3876d4-test"

    uat_azure_subscription = azuredevops_serviceendpoint_azurerm.UAT-SELFCARE.service_endpoint_name
    uat_cdn_endpoint       = "selc-u-checkout-cdn-endpoint"
    uat_cdn_profile        = "selc-u-checkout-cdn-profile"
    uat_resource_group     = "selc-u-checkout-fe-rg"
    uat_storage_account    = "selcucheckoutsa"
    uat_analytics_enabled  = "true"
    uat_analytics_mocked   = "false"
    uat_mixpanel_token     = "1d1b09b008638080ab34fe9b75db84fd"
    uat_onetrust_domain_id = "a8f58d7a-7f6a-4fe6-ac02-f95bac3876d4-test" // TODO fixme whene available

    prod_azure_subscription = azuredevops_serviceendpoint_azurerm.PROD-SELFCARE.service_endpoint_name
    prod_cdn_endpoint       = "selc-p-checkout-cdn-endpoint"
    prod_cdn_profile        = "selc-p-checkout-cdn-profile"
    prod_resource_group     = "selc-p-checkout-fe-rg"
    prod_storage_account    = "selcpcheckoutsa"
    prod_analytics_enabled  = "true"
    prod_analytics_mocked   = "false"
    prod_mixpanel_token     = "1d1b09b008638080ab34fe9b75db84fd"
    prod_onetrust_domain_id = "a8f58d7a-7f6a-4fe6-ac02-f95bac3876d4-test" // TODO fixme whene available

    react_app_assistance_email = "selfcare@assistenza.pagopa.it"

    dev_react_app_url_cdn                      = "https://dev.selfcare.pagopa.it"
    dev_react_app_url_storage                  = "https://selcdcheckoutsa.z6.web.core.windows.net"
    dev_react_app_url_fe_login                 = "https://dev.selfcare.pagopa.it/auth"
    dev_react_app_url_fe_onboarding            = "https://dev.selfcare.pagopa.it/onboarding"
    dev_react_app_url_fe_dashboard             = "https://dev.selfcare.pagopa.it/dashboard"
    dev_react_app_url_fe_assistance            = "https://dev.selfcare.pagopa.it/assistenza"
    dev_react_app_url_fe_landing               = "https://dev.selfcare.pagopa.it/auth/logout" // TODO when the landing will exists, replace this with the correct URL
    dev_react_app_url_api_login                = "https://api.dev.selfcare.pagopa.it/spid/v1"
    dev_react_app_url_api_party_process        = "https://api.dev.selfcare.pagopa.it/party-process/v1"
    dev_react_app_url_api_party_management     = "https://api.dev.selfcare.pagopa.it/party-management/v1"
    dev_react_app_url_api_party_registry_proxy = "https://api.dev.selfcare.pagopa.it/party-registry-proxy/v1"
    dev_react_app_url_api_dashboard            = "https://api.dev.selfcare.pagopa.it/dashboard/v1"
    dev_react_app_url_api_onboarding           = "https://api.dev.selfcare.pagopa.it/onboarding/v1"
    dev_react_app_url_api_notification         = "https://api.dev.selfcare.pagopa.it/ms-notification-manager"
    uat_react_app_url_cdn                      = "https://uat.selfcare.pagopa.it"
    uat_react_app_url_storage                  = "https://selcucheckoutsa.z6.web.core.windows.net"
    uat_react_app_url_fe_login                 = "https://uat.selfcare.pagopa.it/auth"
    uat_react_app_url_fe_onboarding            = "https://uat.selfcare.pagopa.it/onboarding"
    uat_react_app_url_fe_dashboard             = "https://uat.selfcare.pagopa.it/dashboard"
    uat_react_app_url_fe_assistance            = "https://uat.selfcare.pagopa.it/assistenza"
    uat_react_app_url_fe_landing               = "https://uat.selfcare.pagopa.it/auth/logout" // TODO when the landing will exists, replace this with the correct URL
    uat_react_app_url_api_login                = "https://api.uat.selfcare.pagopa.it/spid/v1"
    uat_react_app_url_api_party_process        = "https://api.uat.selfcare.pagopa.it/party-process/v1"
    uat_react_app_url_api_party_management     = "https://api.uat.selfcare.pagopa.it/party-management/v1"
    uat_react_app_url_api_party_registry_proxy = "https://api.uat.selfcare.pagopa.it/party-registry-proxy/v1"
    uat_react_app_url_api_dashboard            = "https://api.uat.selfcare.pagopa.it/dashboard/v1"
    uat_react_app_url_api_onboarding           = "https://api.uat.selfcare.pagopa.it/onboarding/v1"
    uat_react_app_url_api_notification         = "https://api.uat.selfcare.pagopa.it/notifications/v1"

    prod_react_app_url_cdn                      = "https://prod.selfcare.pagopa.it"
    prod_react_app_url_storage                  = "https://selcpcheckoutsa.z6.web.core.windows.net"
    prod_react_app_url_fe_login                 = "https://selfcare.pagopa.it/auth"
    prod_react_app_url_fe_onboarding            = "https://selfcare.pagopa.it/onboarding"
    prod_react_app_url_fe_dashboard             = "https://selfcare.pagopa.it/dashboard"
    prod_react_app_url_fe_assistance            = "https://selfcare.pagopa.it/assistenza"
    prod_react_app_url_fe_landing               = "https://selfcare.pagopa.it/auth/logout" // TODO when the landing will exists, replace this with the correct URL
    prod_react_app_url_api_login                = "https://api.selfcare.pagopa.it/spid/v1"
    prod_react_app_url_api_party_process        = "https://api.selfcare.pagopa.it/party-process/v1"
    prod_react_app_url_api_party_management     = "https://api.selfcare.pagopa.it/party-management/v1"
    prod_react_app_url_api_party_registry_proxy = "https://api.selfcare.pagopa.it/party-registry-proxy/v1"
    prod_react_app_url_api_dashboard            = "https://api.selfcare.pagopa.it/dashboard/v1"
    prod_react_app_url_api_onboarding           = "https://api.selfcare.pagopa.it/onboarding/v1"
    prod_react_app_url_api_notification         = "https://api.selfcare.pagopa.it/notifications/v1"

  }
}
