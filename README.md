# gitops

A collection of common tools to automate our projects configurations.

Find more informaton how to use and contribute in each README.

## Index

1. [Azure DevOps Projects](https://github.com/pagopa/gitops/blob/main/azure-devops)

## Run terraform.sh script

to run the script go into the folder `azure-devops` and launch for example in this ways:

```bash
sh terraform.sh apply <YOUR folder inside the folder: projects>

sh terraform.sh apply selfcare-projects #-> to apply terraform file inside projects\selfcare-projects
```

automatically terraform will find the folder choosed inside the folder projects

## Precommit checks

Check your code before commit.

<https://github.com/antonbabenko/pre-commit-terraform#how-to-install>

```sh
pre-commit run -a
```
