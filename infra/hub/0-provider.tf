terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    features {}
  }

  required_providers {
    azurerm = {
      version = "~>2.85.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~>1.2.8"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
