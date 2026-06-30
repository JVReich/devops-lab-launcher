variable "project_name" {
  type        = string
  description = "Project name prefix."
  default     = "devops-lab"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region."
  default     = "westeurope"
}

variable "location_short" {
  type        = string
  description = "Short Azure region code."
  default     = "weu"
}