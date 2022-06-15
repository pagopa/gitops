terraform {
  required_version = ">= 0.14.5"
  backend "azurerm" {
    resource_group_name  = "io-infra-rg"
    storage_account_name = "ioinfrastterraform"
    container_name       = "azuredevopsstate"
    key                  = "io-iac-projects.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.1.8"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.60.0, <= 2.99.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }
  }
}

provider "azurerm" {
  features {}
}
