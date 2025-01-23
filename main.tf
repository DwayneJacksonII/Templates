#change log 
# 1.0.0 - Initial version 1/16/25
#1.0.1 - Updated for Azure Government use will need to verify the exact API versions supported in your Azure Government subscription.
#1.0.2 - commenting out Environment use for gov updating v1/22/25- dj
#1.0.3 - creation of a resource group, virtual network, and subnet, and prompts the user to select a region 
#All resources including the private endpoint are placed in the created resource group

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
  skip_provider_registration = true

  # Uncomment for Azure Government
  # environment = "usgovernment"
}

# Variables
variable "location" {
  description = "Location for the resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint"
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID of the Azure resource for which the private endpoint needs to be created"
  type        = string
}

variable "group_id" {
  description = "Subresource name of the Azure resource (e.g., 'sites' for Function App)"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "private_dns_zone_name" {
  description = "Private DNS Zone name"
  type        = string
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Private Endpoint
resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet.id

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
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id   = azurerm_virtual_network.vnet.id
  resource_group_name  = azurerm_resource_group.rg.name

  registration_enabled = true
}
