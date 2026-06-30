variable "resource_group_name" {
  description = "Resource group where the virtual network will be created."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vnet_name" {
  description = "Virtual Network name."
  type        = string
}

variable "address_space" {
  description = "Virtual Network address space."
  type        = list(string)
}

variable "subnet_name" {
  description = "AKS subnet name."
  type        = string
}

variable "subnet_prefixes" {
  description = "AKS subnet address prefixes."
  type        = list(string)
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}