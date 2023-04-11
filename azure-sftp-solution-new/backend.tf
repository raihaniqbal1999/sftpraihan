terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.39.1"
    }
  }

}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "azurerm" {
  subscription_id = var.subscription_id
  //client_id       = var.client_id
  tenant_id = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.project_name}-${var.environment}"
  location = var.location
}