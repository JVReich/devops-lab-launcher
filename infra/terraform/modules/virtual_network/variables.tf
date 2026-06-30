variable "resource_group_name" {
  description = "Resource group where the virtual network will be created."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "virtual_network" {
  description = "Virtual network configuration."
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "aks_subnet" {
  description = "AKS subnet configuration."
  type = object({
    name             = string
    address_prefixes = list(string)
  })
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}