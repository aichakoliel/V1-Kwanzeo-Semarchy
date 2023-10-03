###############################################################################################  
#           Creation Groupe de resource DEV1                                                  #
###############################################################################################

resource "azurerm_resource_group" "rg-DEV01" {
  location = var.resource_group_DEV01_location
  name     = var.resource_group_DEV01_name
}

###############################################################################################  
#           Creation virtual network avec NSG                                                 #
###############################################################################################

#NSG
resource "azurerm_network_security_group" "nsg-DEV01" {
  name                = var.network_security_group_DEV01_name
  location            = azurerm_resource_group.rg-DEV01.location
  resource_group_name = azurerm_resource_group.rg-DEV01.name
}

resource "azurerm_network_security_rule" "http-inbound" {
  name                        = "http-inbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-DEV01.name
  network_security_group_name = azurerm_network_security_group.nsg-DEV01.name
}

resource "azurerm_network_security_rule" "https_inbound" {
  name                        = "https-inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-DEV01.name
  network_security_group_name = azurerm_network_security_group.nsg-DEV01.name
}

#Virtual network
resource "azurerm_virtual_network" "vnet-DEV01" {
  name                = var.virtual_network_DEV01_name
  location            = azurerm_resource_group.rg-DEV01.location
  resource_group_name = azurerm_resource_group.rg-DEV01.name
  address_space       = var.virtual_network_DEV01_address_space
  #dns_servers         = ["10.0.0.4", "10.0.0.5"]

}

resource "azurerm_subnet" "subnet-DEV01" {
  name                 = var.subnet_DEV01_name
  resource_group_name  = azurerm_resource_group.rg-DEV01.name
  virtual_network_name = azurerm_virtual_network.vnet-DEV01.name
  address_prefixes     = var.subnet_DEV01_address_prefixes
}

###############################################################################################  
#           Creation Network Interface                                                        #
###############################################################################################

#IP public
resource "azurerm_public_ip" "publicip" {
  name                = "my-public-ip"
  location            = azurerm_resource_group.rg-DEV01.location
  resource_group_name = azurerm_resource_group.rg-DEV01.name
  allocation_method   = "Static"
}
#Network Interface NIC
resource "azurerm_network_interface" "nic-DEV01" {
  name                = var.network_interface_DEV01_name
  location            = azurerm_resource_group.rg-DEV01.location
  resource_group_name = azurerm_resource_group.rg-DEV01.name

  ip_configuration {
    name                          = var.ip_configuration_nic_DEV01.name
    subnet_id                     = azurerm_subnet.subnet-DEV01.id
    private_ip_address_allocation = var.ip_configuration_nic_DEV01.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

###############################################################################################  
#           Creation Virtual machine DEV01                                                    #
###############################################################################################

resource "azurerm_virtual_machine" "vm-DEV01" {
  name                  = var.virtual_machine_name
  location              = azurerm_resource_group.rg-DEV01.location
  resource_group_name   = azurerm_resource_group.rg-DEV01.name
  network_interface_ids = [azurerm_network_interface.nic-DEV01.id]
  vm_size               = var.size

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher    = var.image_reference_vm1.publisher
    offer        = var.image_reference_vm1.offer
    sku          = var.image_reference_vm1.sku
    version      = var.image_reference_vm1.version
  }

storage_os_disk {
    name              = var.os_disk_vm1.name
    caching           = var.os_disk_vm1.caching
    create_option     = var.os_disk_vm1.create_option
    managed_disk_type = var.os_disk_vm1.managed_disk_type
  }

  os_profile{
    computer_name   = "profilvm"
    admin_username  = var.admin_username
    admin_password  = var.admin_password

  }

  os_profile_windows_config {
   #disable_password_authentication = false
  }
}

###############################################################################################  
#           Creation Subnet pour PostgreSQL srver                                             #
###############################################################################################

resource "azurerm_subnet" "subnet-psql-server" {
  name                 = "psql-subnet"
  resource_group_name  = azurerm_resource_group.rg-DEV01.name
  virtual_network_name = azurerm_virtual_network.vnet-DEV01.name
  address_prefixes     = ["10.10.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

###############################################################################################  
#           Creation Bases de données PostgreSQL Flixible Server                                             #
###############################################################################################

#DNS ZONE
resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "sql-server-dev01.private.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg-DEV01.name
}

#DNS link
resource "azurerm_private_dns_zone_virtual_network_link" "dns-link" {
  name                  = "kwanzeoVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet-DEV01.id
  resource_group_name   = azurerm_resource_group.rg-DEV01.name
}

#Sql Server
resource "azurerm_postgresql_flexible_server" "PSQlServer" {
  name                = var.postgresql_server_DEV01.name
  location            = azurerm_resource_group.rg-DEV01.location
  resource_group_name = azurerm_resource_group.rg-DEV01.name
  version             = "11" #var.postgresql_server_dev1.version
  delegated_subnet_id = azurerm_subnet.subnet-psql-server.id

  private_dns_zone_id = azurerm_private_dns_zone.dns-zone.id

  sku_name            = var.postgresql_server_DEV01.sku_name
  zone                = "1"

  storage_mb                   = var.postgresql_server_DEV01.storage_mb
  backup_retention_days        = var.postgresql_server_DEV01.backup_days
  geo_redundant_backup_enabled = false
  #auto_grow_enabled            = true

  administrator_login    = var.postgresql_server_DEV01.login
  administrator_password = var.postgresql_server_DEV01.password
  #ssl_enforcement_enabled      = true

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns-link]
}

#Database
resource "azurerm_postgresql_flexible_server_database" "data" {
 name      = var.postgresql_database_DEV01.name
 server_id = azurerm_postgresql_flexible_server.PSQlServer.id
 collation = var.postgresql_database_DEV01.collation
 charset   = var.postgresql_database_DEV01.charset

}

#Data lock ~ not delete ~
resource "azurerm_management_lock" "data-lock" {
  name       = "data-lock"
  scope      = azurerm_postgresql_flexible_server_database.data.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed by a third-party"
}
