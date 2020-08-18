provider "azurerm" {
  version = "=2.23.0"
  subscription_id = var.azSubscriptionId
  tenant_id       = var.azTenantId
}