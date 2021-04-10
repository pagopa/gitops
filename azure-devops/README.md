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
export AZDO_ORG_SERVICE_URL="https://dev.azure.com/pagopa-io"
export AZDO_PERSONAL_ACCESS_TOKEN="__YOUR_PERSONAL_ACCESS_TOKEN__"
```

## How to

Create a new project or a pipeline into appropriate directory.

    .
    ├── ...
    ├── new-azuredevops-projects
    │ ├── project.tf
    │ ├── provider.tf
    │ ├── secrets.tf
    │ ├── service_connections.tf
    │ ├── time_sleep.tf
    │ ├── github_repo_name_1.tf     # all pipelines in github_repo_name_1
    │ ├── ...
    │ └── github_repo_name_n.tf     # all pipelines in github_repo_name_n
    └── ...

1. if your project contains more github repos add all pipelines in the same azure devops project 
2. for each github repo create a new file with github repo name
3. put all github repo pipelines into same file `github_repo_name_1.tf`
4. put all pipelines variables at beginning of `github_repo_name_1.tf`

:warning: **Very Important**

Before apply any changes be sure that permissions on github repo are set as follow:
1. user `pagopa-github-bot` -> Role: admin

### Apply changes

To apply changes follow the standard terraform lifecycle once the code in this repository has been changed:

```sh
az account set --subscription PROD-IO

terraform init

terraform plan

terraform apply
```

## Custom provider

Actually we use a custom azuredevops terraform provider until these pr will be relaesed:

1. npm service endpoints [#microsoft/terraform-provider-azuredevops/335](https://github.com/microsoft/terraform-provider-azuredevops/pull/335)

Current custom azuredevops provider version: **v0.1.3-beta.1**

### How to install custom provider

1. Download custom azuredevops provider from [#pagopa/terraform-provider-azuredevops](https://github.com/pagopa/terraform-provider-azuredevops/releases)
2. Copy it on your plugin version dir `"${HOME}/.terraform.d/plugin-cache/registry.terraform.io/microsoft/azuredevops"`
3. in `azure-devops/projects` and delete all `.terraform` folder and `.terraform.lock.hcl files`
4. `terraform init --upgrade`

```sh
# install custom azuredevops terraform provider
VERSION="0.1.3"
CUSTOM_VERSION="0.1.3-beta.1"
OS="darwin" #or linux
OS_ARCH="amd64" #or 386, arm, arm64...

wget "https://github.com/pagopa/terraform-provider-azuredevops/releases/download/v${CUSTOM_VERSION}/terraform-provider-azuredevops_${CUSTOM_VERSION}_${OS}_${OS_ARCH}.zip"
unzip "terraform-provider-azuredevops_${CUSTOM_VERSION}_${OS}_${OS_ARCH}.zip"
rm "terraform-provider-azuredevops_${CUSTOM_VERSION}_${OS}_${OS_ARCH}.zip"
mkdir -p "${HOME}/.terraform.d/plugin-cache/registry.terraform.io/microsoft/azuredevops/${VERSION}/${OS}_${OS_ARCH}"
mv "terraform-provider-azuredevops_v${CUSTOM_VERSION}" "${HOME}/.terraform.d/plugin-cache/registry.terraform.io/microsoft/azuredevops/${VERSION}/${OS}_${OS_ARCH}/terraform-provider-azuredevops_v${VERSION}"

# in azure-devops/projects and delete all .terraform folder and .terraform.lock.hcl files
terraform init --upgrade
```
