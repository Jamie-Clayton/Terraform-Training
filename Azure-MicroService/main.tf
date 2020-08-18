provider "azurerm" {
  version         = "=2.23.0"
  subscription_id = var.azSubscriptionId
  tenant_id       = var.azTenantId
  features {}
}

# Resource Group to store all the related objects.
resource "azurerm_resource_group" "envgrp" {  
  name      = module.resource_group_name.result
  location  = local.location
  tags      = var.azDefaultTags
}

# Storeage account (LowerCaseOnly)
resource "azurerm_storage_account" "storage" {
  name                     = module.storage_account_name.result
  resource_group_name      = azurerm_resource_group.envgrp.name
  location                 = local.location
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
  tags                     = var.azDefaultTags
}

# Create Storage and share for portal.azure.com Shell commands (Powershell/Bash)
resource "azurerm_storage_account" "shellstorage" {
  name                     = module.shell_storage_account_name.result
  resource_group_name      = azurerm_resource_group.envgrp.name
  location                 = local.location
  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  tags                     = merge({ ms-resource-usage = "azure-cloud-shell" }, var.azDefaultTags)
}

# Create a service principle(s) to help automation tools to connect with appropriate restrictions (E.g. Apps to a resource group etc)
# https://stackoverflow.com/questions/53991906/azure-terraform-creating-service-principal-and-using-that-principal-in-a-provid
