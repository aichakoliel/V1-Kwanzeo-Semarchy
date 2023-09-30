#################  variables Groupe de Resource Rg-HUB ###########################

variable "resource_group_location" {
  default     = "West Europe"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "RG-Hub-Kwanzeo-Semarchy"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

################# variables Virtuel Network - Vnet Hub -###########################

variable "virtual_network_name" {
  default = "vnet-Hub-Kwanzeo-Semarchy"
}

variable "address_space" {
  default = ["10.0.0.0/16"]

}

################# Subnet Frontend , Backend ###########################
variable "subnet_frontend_name" {
  default = "FrontendSubnet-Hub-Kwanzeo-Semarchy"

}
variable "address_prefixes_frontend" {
  default = ["10.0.1.0/24"]
}

variable "subnet_backend_name" {
  default = "BackendSubnet-Hub-Kwanzeo-Semarchy"

}
variable "address_prefixes_backend" {
  default = ["10.0.2.0/24"]
}

################# l'application Gateway  #############################

# variable "create_App_Gateway" {

#   type    = bool
#   default = false
# }

## ip public gateway
variable "public_ip_gateway_name" {
  default = "GatewayPublicIPAddress-Hub-Kwanzeo-Semarchy"
}

variable "allocation_method_gateway" {
  default = "Static"
}

variable "sku_ip_gateway" {
  default = "Standard"
}

### application gateway
variable "appplication_gateway_name" {
  default = "app-gateway-Hub-Kwanzeo-Semarchy"
}

variable "sku_gateway" {
  type = map(any)

  default = {
    capacity = 2
    name     = "WAF_v2"
    tier     = "WAF_v2"
  }
}

variable "gateway_ip_configuration_name" {
  default = "gateway-ip-configuration"
}

variable "backend_address_pool_name" {
  default = "backendPool"
}

variable "frontend_port_name" {
  default = "frontendport"
}

variable "frontend_port" {
  default = 80
}

variable "frontend_ip_configuration_name" {
  default = "frontedip"
}

variable "backend_http_setting" {
  type = map(any)
  default = {
    name                  = "be-http-st"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
}

variable "http_listener_gateway" {
  type = map(any)
  default = {
    name     = "http-lstnr"
    protocol = "Http"
  }
}

variable "request_routing_rule_gateway" {
  type = map(any)
  default = {
    name     = "routingRul"
    type     = "Basic"
    priority = 1
  }
}

variable "redirect_configuration_name" {
  default = "rdrcfg"
}


#################  Subnet Bastion ##########################

variable "subnet_bastion_name" {
  default = "AzureBastionSubnet"
}

variable "subnet_bastion_address_prefixes" {
  default = ["10.0.0.0/27"]
}


#################  Création de IP public Bastion ##########################

variable "public_ip_bastion" {
  type = map(any)
  default = {
    name              = "bastion-ip"
    allocation_method = "Static"
  }
}
variable "bastion_name" {
  default = "Bastion-Hub-Kwanzeo-Semarchy"

}








#################  Subnet VPN ##########################

# variable "subnet_gateway_vpn_name" {
#   default  = "GatewaySubnet"
# }

# variable "subnet_gateway_vpn_address_prefixes" {
#   default = ["10.0.0.0/27"]
# }


# #################  Création des Subnet vpn ##########################

# variable "public_ip_vpn" {
#   type = map
#   default = {
#     name              = "vpn-ip"
#     allocation_method = "Dynamic"
# } 
# }

# variable "virtual_network_gateway_vpn" {
#   type = map
#   default = {
#     name          = "vpnkwanzeo"
#     type          = "Vpn"
#     vpn_type      = "RouteBased"
#   # active_active = false
#   # enable_bgp    = false
#     sku           = "Basic"
#   } 

# }


# variable "ip_configuration_gateway" {
#   type = map
#   default = {
#     name                          = "vnetGatewayConfig"
#     private_ip_address_allocation = "Dynamic"
#   }   
# }
