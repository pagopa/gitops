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

  selc-be-uservice-common-variables_deploy = {
    manager_platform_roles  = "Manager"//TODO admin
    delegate_platform_roles = "Delegate"//TODO admin
    operator_platform_roles = "Operator"//TODO security,api

    dev_replicas                     = 1
    dev_storage_container            = "selc-d-contracts-blob"
    dev_storage_endpoint             = "core.windows.net"
    dev_party_process_url            = "http://uservice-party-process:8088/uservice-party-process/0.1"
    dev_party_management_url         = "http://uservice-party-management:8088/uservice-party-management/0.1"
    dev_party_proxy_url              = "http://uservice-party-registry-proxy:8088/uservice-party-registry-proxy/0.1"
    dev_attribute_registry_url       = "http://uservice-attribute-registry-management:8088/uservice-attribute-registry-management/0.1"
    dev_authorization_process_url    = "http://uservice-authorization-process:8088/uservice-authorization-process/0.1" // TODO this will be removed and replaced with hub spid login
    dev_user_registry_management_url = "http://uservice-registry-management:8088/uservice-registry-management/0.1" // TODO this will point to userRegistry

    uat_replicas                     = 1
    uat_storage_container            = "selc-u-contracts-blob"
    uat_storage_endpoint             = "core.windows.net"
    uat_party_process_url            = "http://uservice-party-process:8088/uservice-party-process/0.1"
    uat_party_management_url         = "http://uservice-party-management:8088/uservice-party-management/0.1"
    uat_party_proxy_url              = "http://uservice-party-registry-proxy:8088/uservice-party-registry-proxy/0.1"
    uat_attribute_registry_url       = "http://uservice-attribute-registry-management:8088/uservice-attribute-registry-management/0.1"
    uat_authorization_process_url    = "http://uservice-authorization-process:8088/uservice-authorization-process/0.1" // TODO this will be removed and replaced with hub spid login
    uat_user_registry_management_url = "http://uservice-registry-management:8088/uservice-registry-management/0.1" // TODO this will point to userRegistry

    prod_replicas                     = 1
    prod_storage_container            = "selc-p-contracts-blob"
    prod_storage_endpoint             = "core.windows.net"
    prod_party_process_url            = "http://uservice-party-process:8088/uservice-party-process/0.1"
    prod_party_management_url         = "http://uservice-party-management:8088/uservice-party-management/0.1"
    prod_party_proxy_url              = "http://uservice-party-registry-proxy:8088/uservice-party-registry-proxy/0.1"
    prod_attribute_registry_url       = "http://uservice-attribute-registry-management:8088/uservice-attribute-registry-management/0.1"
    prod_authorization_process_url    = "http://uservice-authorization-process:8088/uservice-authorization-process/0.1" // TODO this will be removed and replaced with hub spid login
    prod_user_registry_management_url = "http://uservice-registry-management:8088/uservice-registry-management/0.1" // TODO this will point to userRegistry
  }
}