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
  resource_group_name      = azurerm_resource_group.envgrp.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  enable_https_traffic_only = true
  allow_blob_public_access = true
  tags                     = var.azDefaultTags
  provisioner "local-exec" {
    command = "az storage blob service-properties update --account-name ${self.name} --static-website  --index-document index.html --404-document 404.html"

  }
  depends_on = [azurerm_resource_group.envgrp]
}

resource "azurerm_storage_container" "cdnStorageContainer" {
  name                  = local.org
  storage_account_name  = azurerm_storage_account.cdnStorage.name
  container_access_type = "container"
}

resource "null_resource" "tempWebPages" {
  provisioner "local-exec" {
    command     = "az storage blob upload-batch --source ../web-under-construction-app --destination ${local.org}"
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
  resource_group_name = azurerm_resource_group.envgrp.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "cdnEndpoint" {
  name                = module.cdn_endpoint_name.result 
  profile_name        = azurerm_cdn_profile.cdnProfile.name
  location            = local.location
  resource_group_name = azurerm_resource_group.envgrp.name
  origin_host_header  = basename(azurerm_storage_account.cdnStorage.primary_web_endpoint)
  origin {
    name      = azurerm_storage_account.cdnStorage.name
    host_name = basename(azurerm_storage_account.cdnStorage.primary_web_endpoint)
  }
}