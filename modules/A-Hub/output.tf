output "vnet-hub-id" {
  value = azurerm_virtual_network.hub-vnet.id
}

output "rg-hub-name" {
  value = azurerm_resource_group.rg.name

}

output "vnet-hub-name" {
  value = azurerm_virtual_network.hub-vnet.name
}