variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "cluster" {
  type = object({
    name                = string
    dns_prefix          = string
    kubernetes_version  = string
    node_resource_group = string
  })
}

variable "default_node_pool" {
  type = object({
    node_count = number
    vm_size    = string
    subnet_id  = string
  })
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}