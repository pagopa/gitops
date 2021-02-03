terraform {
  backend "azurerm" {
    resource_group_name  = "io-infra-rg"
    storage_account_name = "ioinfrastterraform"
    container_name       = "azuredevopsstate"
    key                  = "io-backend-projects.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.1.1"
    }
    azurerm = {
      version  = "~> 2.42.0"
      features = {}
    }
    time = {
      version = "~> 0.6.0"
    }
  }
}
