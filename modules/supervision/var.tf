#################  variables Groupe de Resource Rg-SUP ###########################

variable "resource_group_location" {
  default     = "West Europe"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "RG-Supervision-Kwanzeo-Semarchy"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

################# variables Storage Account ###########################

variable "storage_account_name" {
    default = "kwanzeostorageaccount"
  
}

################# variables Log-analytic ###########################

variable"log_analytics_name" {
    default = "kwanzeo-log"
}