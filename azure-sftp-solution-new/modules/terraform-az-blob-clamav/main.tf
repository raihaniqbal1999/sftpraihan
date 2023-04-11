terraform {
  // lock terraform to version 1.0.0+
  required_version = ">= 1.3.0"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.39.1"
    }


    null = {
      source  = "hashicorp/null"
      version = ">=3.1.0"
    }
  }
}

locals {
  tags = {
    Environment = var.environment
    CreatedBy   = var.repository
  }
}