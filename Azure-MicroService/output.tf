output "StorageKey" {
    value = azurerm_storage_account.storage.primary_access_key
}

output "StorageName" {
    value = azurerm_storage_account.storage.name
}

output "ServiceBusConnectionString" {
    value = azurerm_servicebus_namespace_authorization_rule.queuesecurity.primary_connection_string
}

output "FileShare-Shell" {
    value = azurerm_storage_share.shellShare.url
} 