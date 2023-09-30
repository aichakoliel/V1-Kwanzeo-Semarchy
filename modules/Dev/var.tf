##################  Groupe de resource DEV01 - ########################

variable "resource_group_DEV01_location" {
  default     = "West Europe"
  description = "Location of the resource group."
}

variable "resource_group_DEV01_name" {
  default     = "RG-DEV01-Kwanzeo-Semarchy"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

##################  virtual network avec NSG - ########################

variable "network_security_group_DEV01_name" {
  default = "nsg-DEV01"  
}

variable "virtual_network_DEV01_name" {
  default = "vnet-DEV01"
}

variable "virtual_network_DEV01_address_space" {
  default = ["10.10.0.0/16"]
}

variable "subnet_DEV01_name" {
  default = "subnet-DEV01"
}

variable "subnet_DEV01_address_prefixes" {
  default = ["10.10.1.0/24"]
}

####################   Network Interface   #####################################

variable "network_interface_DEV01_name" {
  default = "nic-DEV01"
}

variable "ip_configuration_nic_DEV01" {
  type = map
  default = {
    name                          = "configurationDEV011"
    private_ip_address_allocation = "Dynamic"
  }  
}

##################   Virtual machine DEV01 ########################
variable "virtual_machine_name" {
  default = "vm-DEV01"
  
}

# variable "windows_2019_sku" { 
#   type = string 
#   default = "2019-Datacenter"
#   }

variable "size" {
  default = "Standard_DS1_v2"  #"Standard_B2ms"
  
}

variable "admin_username" {
  default = "admin-DEV01"

}

variable "admin_password" {
  default = "Kwanzeo1234!"
  
}

variable os_disk_vm1 {
  type = object({
    name              = string
    caching           = string
    create_option     = string
    managed_disk_type = string

    })
    default = {
      name              = "osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    }
  }

  variable image_reference_vm1 {
    type = object({
      publisher  = string
      offer      = string
      sku        = string
      version    = string

    })
    default = {
      publisher  = "MicrosoftWindowsServer"
      offer      = "WindowsServer"
      sku        = "2019-Datacenter"
      version    = "latest"
    }
  }
##################   Bases de données PostgreSQL ########################
variable "postgresql_server_DEV01" {
  type = map
  default = {
    name          = "sql-server-dev01"
    sku_name      = "GP_Standard_D4s_v3" #"B_Gen5_2"
    storage_mb    = 32768  #5120
    backup_days   = 7 
    login         = "psqladmin"
    password      = "H@Sh1CoR3!"
    #version       = "9.5"

  }
}

#Database
variable "postgresql_database_DEV01" {
  type = map
  default = {
    name                = "datapsqlDEV01"
    charset             = "UTF8"
    collation           = "en_US.UTF8"   #"English_United States.1252"
  }
}