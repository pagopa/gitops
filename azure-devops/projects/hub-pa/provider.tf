terraform {
  required_version = ">= 0.14.5"
  backend "azurerm" {
    resource_group_name  = "io-infra-rg"
    storage_account_name = "ioinfrastterraform"
    container_name       = "azuredevopsstate"
    key                  = "hub-pa-projects.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.1.2"
    }
    azurerm = {
      version = "~> 2.42.0"
    }
    time = {
      version = "~> 0.6.0"
    }
  }
}
