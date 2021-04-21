terraform {
  required_version = ">= 0.14.5"
  backend "azurerm" {
    resource_group_name  = "io-infra-rg"
    storage_account_name = "ioinfrastterraform"
    container_name       = "azuredevopsstate"
    key                  = "io-services-metadata-projects.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "= 0.1.3"
    }
    azurerm = {
      version = "~> 2.52.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.4.0"
    }
    time = {
      version = "~> 0.6.0"
    }
  }
}
