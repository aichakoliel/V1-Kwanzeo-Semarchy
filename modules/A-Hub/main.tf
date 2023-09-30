#################  Création du groupe de resource RgCommun ###########################

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}


##################  Creation Virtuel Network - Vnet Hub - #########################

resource "azurerm_virtual_network" "hub-vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space

  tags = {
    environment = "hub"
  }
}

#################  Création des Subnet Frontend , Backend ##########################    

resource "azurerm_subnet" "frontendSubnet" {
  name                 = var.subnet_frontend_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = var.address_prefixes_frontend
}

resource "azurerm_subnet" "backendSubnet" {
  name                 = var.subnet_backend_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = var.address_prefixes_backend
}

#################  Création de l'application Gateway  #############################
# avec un ip public et la configuration de ip (gateway, frontend , backend pool )
# et la configuration de port frontend et backend et les rule de routage 

resource "azurerm_public_ip" "publicip" {
  #count               = var.create_App_Gateway ? 1 : 0
  name                = var.public_ip_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = var.allocation_method_gateway
  sku                 = var.sku_ip_gateway
}

### application_security_group WAF
resource "azurerm_application_security_group" "waf_security_group" {
  name                = "my-waf-security-group"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_web_application_firewall_policy" "waf-policy" {
  name                = "my-waf-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  custom_rules {
    name      = "Rule1"
    priority  = 1
    rule_type = "MatchRule"

    match_conditions {
      match_variables {
        variable_name = "RemoteAddr"
      }

      operator           = "IPMatch"
      negation_condition = false
      match_values       = ["192.168.1.0/24", "10.0.0.0/24"]
    }

    action = "Block"
  }

  managed_rules {
    exclusion {
      match_variable          = "RequestHeaderNames"
      selector                = "x-company-secret-header"
      selector_match_operator = "Equals"
    }
    exclusion {
      match_variable          = "RequestCookieNames"
      selector                = "too-tasty"
      selector_match_operator = "EndsWith"
    }

    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      rule_group_override {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rule {
          id      = "920300"
          enabled = true
          action  = "Log"
        }

        rule {
          id      = "920440"
          enabled = true
          action  = "Block"
        }
      }
    }
  }
}

resource "azurerm_application_gateway" "AppGateway" {
  #count               = var.create_App_Gateway ? 1 : 1

  name                = var.appplication_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = var.sku_gateway.name
    tier     = var.sku_gateway.tier
    capacity = var.sku_gateway.capacity
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.frontendSubnet.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.backend_http_setting.name
    cookie_based_affinity = var.backend_http_setting.cookie_based_affinity
    port                  = var.backend_http_setting.port
    protocol              = var.backend_http_setting.protocol
    request_timeout       = var.backend_http_setting.request_timeout
  }

  http_listener {
    name                           = var.http_listener_gateway.name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = var.http_listener_gateway.protocol
  }

  request_routing_rule {
    name                       = var.request_routing_rule_gateway.name
    rule_type                  = var.request_routing_rule_gateway.type
    http_listener_name         = var.http_listener_gateway.name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.backend_http_setting.name
    priority                   = var.request_routing_rule_gateway.priority
  }

  waf_configuration  {
    enabled            = true
    firewall_mode            = "Detection"
    rule_set_version         = "3.1"
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128

  }
}

##################  Création des Subnet Bastion ########################## 

resource "azurerm_subnet" "BstionSubnet" {
  name                 = var.subnet_bastion_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = var.subnet_bastion_address_prefixes
}

################### Création d'une adresse IP publique pour le bastion##################

resource "azurerm_public_ip" "bastion_public_ip" {
  name                = var.public_ip_bastion.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = var.public_ip_bastion.allocation_method
  sku                 = "Standard"

  tags = {
    environment = "dev"
  }
}

################### Création du bastion  ####################################

resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "bastion-ip"
    subnet_id            = azurerm_subnet.BstionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }

  tags = {
    environment = "dev"
  }
}

# resource "azurerm_virtual_network_peering" "hub-to-spok" {
#   name                      = "peer1to2"
#   resource_group_name       = azurerm_resource_group.rg.name
#   virtual_network_name      = azurerm_virtual_network.hub-vnet.name
#   remote_virtual_network_id = azurerm_virtual_network.vinet-dev1.id
# }

