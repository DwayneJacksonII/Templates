#change log 
# 1.0.0 - Initial version 1/16/25
#1.0.1 - Updated for Azure Government use will need to verify the exact API versions supported in your Azure Government subscription.
#1.0.2 - commenting out Environment use for gov updating v1/22/25- dj

# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.64.0" # Replace with the latest supported version
    }
  }
}

provider "azurerm" {
  features {}

  # Uncomment for Azure Government
  # environment = "usgovernment"
}

# Variables
variable "location" {
  description = "Location for the private endpoint"
  default     = null
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
}

variable "target_resource_id" {
  description = "Resource ID of the Azure resource for which the private endpoint needs to be created"
}

variable "group_id" {
  description = "Subresource name of the Azure resource (e.g., 'sites' for Function App)"
}

variable "vnet_name" {
  description = "Virtual network name where private endpoint will be created"
}

variable "subnet_name" {
  description = "Subnet name where private endpoint will be created"
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone Resource ID"
}

# Data Sources
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

# Resource Group (example resource group, replace as needed)
resource "azurerm_resource_group" "rg" {
  name     = "example-resource-group"
  location = var.location != null ? var.location : "eastus"
}

# Private Endpoint
resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = var.location != null ? var.location : azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id

  private_service_connection {
    name                           = var.private_endpoint_name
    private_connection_resource_id = var.target_resource_id
    subresource_names              = [var.group_id]
    is_manual_connection           = false
  }

  tags = {
    Environment = "Production"
  }
}

# DNS Zone Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link" {
  name                 = "example-dns-link"
  private_dns_zone_id  = var.private_dns_zone_id
  virtual_network_id   = data.azurerm_virtual_network.vnet.id
  resource_group_name  = azurerm_resource_group.rg.name

  registration_enabled = true
}
