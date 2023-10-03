output "vnet-dev-id" {
    value = azurerm_virtual_network.vnet-DEV01.id
}

output "rg-dev-name" {
    value = azurerm_resource_group.rg-DEV01.name
}

output "vnet-dev-name" {
    value = azurerm_virtual_network.vnet-DEV01.name
}