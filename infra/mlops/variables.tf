variable "name" {
  description = "Base infra name"
  type        = string
  default     = "sbmlops"
}
variable "prefixes" {
  description = "Name prefixes"
  type        = list(string)
  default     = []
}

variable "suffixes" {
  description = "Name suffixes"
  type        = list(string)
  default     = []
}

variable "random_length" {
  description = "Number of random characters in name"
  type        = number
  default     = 0
}

variable "location" {
  description = "Resource location"
  type        = string
  default     = "uksouth"
}

variable "hub_rg_name" {
  description = "Hub resource group name"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub vnet name"
  type        = string
}

variable "subnet_address_space" {
  description = "IP address space for the subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}
