# Azure DevOps

This folder is for managing **Azure DevOps** projects and pipelines.

## Requirements

### 1. terraform

In order to manage the suitable version of terraform it is strongly recommended to install the following tool:

- [tfenv](https://github.com/tfutils/tfenv): **Terraform** version manager inspired by rbenv.

Once these tools have been installed, install the terraform version version shown in:

- .terraform-version

After installation install terraform:

```sh
tfenv install
```

### 2. Azure CLI

In order to authenticate to Azure Infrastructure and manage terraform state it's necessary to install and login to Azure subscription.

- [Azure CLI](https://docs.microsoft.com/it-it/cli/azure/install-azure-cli)

After installation login to Azure:

```sh
az login
```

### 3. Azure DevOps Personal Access Token

In order to authenticate to Azure DevOps ad manage pipelines you need to create and set a Personal Access Token.

- [Azure DevOps Personal Access Token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

After create your token export it, for example in your bash_profile

```sh
# .bash_profile
export AZDO_ORG_SERVICE_URL=https://dev.azure.com/pagopa-io
export AZDO_PERSONAL_ACCESS_TOKEN=__YOUR_PERSONAL_ACCESS_TOKEN__
```

## How to

TBD

### Apply changes

to apply changes or create new groups follow the standard terraform lifecycle once the code in this repository has been changed:

```sh
az account set --subscription PROD-IO

terraform init

terraform plan

terraform apply
```

## Custom provider

Actually we use a custom azuredevop terraform provider to manage:

1. npm service endpoints [#microsoft/terraform-provider-azuredevops/335](https://github.com/microsoft/terraform-provider-azuredevops/pull/335)

Custom azuredevops provider version: **v0.1.3-beta.1**

### How to install custom provider

1. Download custom azuredevops provider from [#pagopa/terraform-provider-azuredevops](https://github.com/pagopa/terraform-provider-azuredevops/releases)
1. Copy it on your plugin dir: "${TF_PLUGIN_CACHE_DIR}/registry.terraform.io/microsoft/azuredevops/"
