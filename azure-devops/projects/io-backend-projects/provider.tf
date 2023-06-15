terraform {
  required_version = ">= 0.14.5"
  backend "azurerm" {
    resource_group_name  = "io-infra-rg"
    storage_account_name = "ioinfrastterraform"
    container_name       = "azuredevopsstate"
    key                  = "io-backend-projects.terraform.tfstate"
  }
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">= 0.3.0"
    }
    azurerm = {
      version = ">= 2.99.0"
    }
    time = {
      version = ">= 0.7.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias           = "prod-io"
  subscription_id = module.secrets.values["PAGOPAIT-PROD-IO-SUBSCRIPTION-ID"].value
}

provider "azurerm" {
  features {}
  alias           = "dev-io"
  subscription_id = module.secrets.values["PAGOPAIT-DEV-IO-SUBSCRIPTION-ID"].value
}
