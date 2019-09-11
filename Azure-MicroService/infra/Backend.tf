# Resource Group to store all the related objects.
resource "azurerm_resource_group" "envgrp" {  
  name      = join("-", [var.Env, "rg"] )
  location  = var.azLocation
  tags      = var.azDefaultDevTags
}

# Queue services for Producer/Consumer software pattern.
resource "azurerm_servicebus_namespace" "queue" {
  name                = join("-", [ var.Env, "sbus" ] )
  resource_group_name = azurerm_resource_group.envgrp.name
  location            = azurerm_resource_group.envgrp.location
  sku                 = "Standard"
  tags                = var.azDefaultDevTags
}

resource "azurerm_servicebus_namespace_authorization_rule" "queuesecurity" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_servicebus_namespace.queue.name
  resource_group_name = azurerm_resource_group.envgrp.name

  listen = true
  send   = true
  manage = true
}