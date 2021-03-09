# Io Authorization

This folder is for managing **Azure DevOps** projects and pipelines.

## Requirements

In order to manage the suitable version of terraform it is strongly recommended to install the following tool:

- [tfenv](https://github.com/tfutils/tfenv): **Terraform** version manager inspired by rbenv.

Once these tools have been installed, install the terraform version version shown in:

- .terraform-version

## How to

So far all groups are defined within a single variable [**groups**](https://github.com/pagopa/io-authorization/blob/main/terraform.tfvars) which is a list of groups, members and roles for each group.
Roles are assigned to groups with scope at the **subcription level**.
It's possible to assign roles with different scope, but it's required to add more logic inside the **main.tf** file.

### Apply changes

to apply changes or create new groups follow the standard terraform lifecycle once the code in this repository has been changed:

```
$ az account set --subscription PROD-IO

$ terraform init

$ terraform plan

$ terraform apply
```
