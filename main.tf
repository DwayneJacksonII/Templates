# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Update to a specific version if needed for Azure Government
    }
  }
}

provider "azurerm" {
  features {}

  # Use Azure Government cloud
  environment = "usgovernment"
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
  description = "Subresource name of the Azure resource (e.g., 'blob' for storage account)"
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
  location = var.location != null ? var.location : "usgovvirginia"
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

# Private DNS Zone Group
resource "azurerm_private_dns_zone_group" "dns_zone_group" {
  name                 = "default"
  private_endpoint_id  = azurerm_private_endpoint.private_endpoint.id

  private_dns_zone_config {
    name                  = "default"
    private_dns_zone_id   = var.private_dns_zone_id
  }
}
