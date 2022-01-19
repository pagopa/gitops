# gitops for azure devops

A collection of common tools to automate our projects configurations.

Find more informaton how to use and contribute in each README.

## Index

1. [Azure DevOps Projects](https://github.com/pagopa/gitops/blob/main/azure-devops)

## Apply/Plan changes running terraform.sh script

to run the script go into the folder `azure-devops` and launch for example in this ways:

```bash
sh terraform.sh apply <YOUR folder inside the folder: projects>

sh terraform.sh apply selfcare-projects #-> to apply terraform file inside projects\selfcare-projects
```

automatically terraform will find the folder choosed inside the folder projects

## Update aks configurations to pipelines

before create aks pipelines is mandatory to run the script `setup_aks_sa_secrets.sh` under the folder: `gitops/azure-devops/scripts` it allows to generate the secrets used by the pipelines to reach the aks.

## :warning: aks configuration or cluster changed

In case the pipelines and the service connection is alredy created and something changed into aks cluster.
For example the cluster changed some configuration or was re-created.

you must to:

1. execute the script `setup_aks_sa_secrets.sh`
2. taint the resources related to aks service connection like:

    ```json
    # DEV service connection for azure kubernetes service
    resource "azuredevops_serviceendpoint_kubernetes" "selfcare-aks-dev" {
        depends_on            = [azuredevops_project.project]
        project_id            = azuredevops_project.project.id
        service_endpoint_name = "selfcare-aks-dev"
        apiserver_url         = module.secrets.values["dev-selfcare-aks-apiserver-url"].value
        authorization_type    = "ServiceAccount"
        service_account {
            # base64 values
            token   = module.secrets.values["dev-selfcare-aks-azure-devops-sa-token"].value
            ca_cert = module.secrets.values["dev-selfcare-aks-azure-devops-sa-cacrt"].value
        }
    }
    ```

    in this way:

    ```bash
    sh terraform.sh taint selfcare-projects  azuredevops_serviceendpoint_kubernetes.selfcare-aks-dev;
    ```

3. re-launch the pipeline creation to allow the recreation of the pipelines, this proccess allow to update all the information needed by service connection and pipeline

## Precommit checks

Check your code before commit.

<https://github.com/antonbabenko/pre-commit-terraform#how-to-install>

```sh
pre-commit run -a
```
