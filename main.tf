#################  Création de l'envirenement HUB ##########################    
module "hub" {
  source = "./modules/A-Hub"

}

#################  Création de l'envirenement DEV-1 ##########################    

module "dev" {
  source = "./modules/Dev"

  #version   = "9.5"

}

resource "azurerm_virtual_network_peering" "hub-to-dev" {
  name                      = "hub-to-dev01"               #"hub-to-spok"
  resource_group_name       = module.hub.rg-hub-name   #azurerm_resource_group.rg.name
  virtual_network_name      = module.hub.vnet-hub-name #azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = module.dev.vnet-dev-id #azurerm_virtual_network.vinet-dev1.id
}

resource "azurerm_virtual_network_peering" "dev-to-hub" {
  name                      = "dev01-to-hub"
  resource_group_name       = module.dev.rg-dev-name  #azurerm_resource_group.rg-dev1.name
  virtual_network_name      = module.dev.vnet-dev-name #azurerm_virtual_network.vinet-dev1.name
  remote_virtual_network_id = module.hub.vnet-hub-id     #azurerm_virtual_network.hub-vnet.id
}
