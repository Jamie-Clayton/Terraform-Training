provider "azurerm" {
  version = "=1.28.0"
  subscription_id = var.azSubscriptionId
  tenant_id       = var.azTenantId
}