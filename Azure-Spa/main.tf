provider "azurerm" {
  version         = "=2.23.0"
  subscription_id = var.azSubscriptionId
  tenant_id       = var.azTenantId
  features {}
}

# Create a resource group for the Angular app
resource "azurerm_resource_group" "envgrp" {
  name      = module.resource_group_name.result
  location  = local.location
  tags      = var.azDefaultTags
}

resource "azurerm_storage_account" "cdnStorage" {
  name                     = module.storage_account_name.result
  location                 = local.location
  resource_group_name      = module.resource_group_name.result
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
  tags                     = var.azDefaultTags
  provisioner "local-exec" {
    command = "az storage blob service-properties update --account-name ${self.name} --static-website  --index-document index.html --404-document 404.html"
  }
}

resource "null_resource" "tempWebPages" {
  provisioner "local-exec" {
    command     = "az storage blob upload-batch --destination '$web' --source ../example-app/dist/example-app"
    environment = {
      AZURE_STORAGE_ACCOUNT = azurerm_storage_account.cdnStorage.name
      AZURE_STORAGE_KEY     = azurerm_storage_account.cdnStorage.primary_access_key
    }
  }
  depends_on = [azurerm_storage_account.cdnStorage]
}

resource "azurerm_cdn_profile" "cdnProfile" {
  name                = module.cdn_profile_name.result
  location            = local.location
  resource_group_name = module.resource_group_name.result
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdnEndpoint" {
  name                = module.cdn_endpoint_name.result 
  profile_name        = module.cdn_profile_name.result
  location            = local.location
  resource_group_name = module.resource_group_name.result
  origin_host_header  = basename(azurerm_storage_account.cdnStorage.primary_web_endpoint)
  origin {
    name      = module.storage_account_name.result
    host_name = basename(azurerm_storage_account.cdnStorage.primary_web_endpoint)
  }
}