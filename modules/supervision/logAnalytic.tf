#################  Création de groupe de resource RgSupervision ###########################

resource "azurerm_resource_group" "rgSupervision" {
  location = var.resource_group_location
  name     = var.rg_supervision_name
}


##################  Creation Storage Account  #########################

resource "azurerm_storage_account" "storage_sup" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rgSupervision.name
  location                 = azurerm_resource_group.rgSupervision.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

##################  Creation Log Anaylytic  #########################

#Specifies the SKU of the Log Analytics Workspace. Possible values are
# Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation,
# and PerGB2018 (new SKU as of 2018-04-03). Defaults to PerGB2018

resource "azurerm_log_analytics_workspace" "log-Anaylytic" {
  name                = var.log_analytics_name
  location            = azurerm_resource_group.rgSupervision.location
  resource_group_name = azurerm_resource_group.rgSupervision.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
