variable "name" {
  description = "Base infra name"
  type        = string
  default     = "sbhub"
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

variable "vnet_address_space" {
  description = "IP address space for the vnet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
  description = "IP address space for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# TODO: the build agent should be in the same vnet;
# the vnet should be an input.
variable "build_agent_ip" {
  description = "IP of agent provisioning infra"
  type        = string
  default     = "82.1.101.43"
}
