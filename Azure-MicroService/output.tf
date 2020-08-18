
output "ResourceGroup" {
    value = azurerm_resource_group.envgrp.name
}

output "DataStorage" {
    value = azurerm_storage_account.storage.name
} 
output "DataStorageKey" {
    value = azurerm_storage_account.storage.primary_access_key
}

output "ShellStorage" {
    value = azurerm_storage_account.shellstorage.name
}
output "ShellStorageKey" {
    value = azurerm_storage_account.shellstorage.primary_access_key
}