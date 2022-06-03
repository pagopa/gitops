terraform {
  required_version = ">= 0.14.5"
  backend "azurerm" {
    resource_group_name  = "io-infra-rg"
    storage_account_name = "ioinfrastterraform"
    container_name       = "azuredevopsstate"
    key                  = "cstar-iac-projects.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.2.0"
    }
    azurerm = {
      version = ">= 2.99.0"
    }
  }
}

provider "azurerm" {
  features {}
}
