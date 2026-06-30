variable "project_name" {
  type        = string
  description = "Project name used as naming prefix."
}

variable "environment" {
  type        = string
  description = "Environment name, for example dev, demo, or prod."
}

variable "location_short" {
  type        = string
  description = "Short Azure region code, for example weu for West Europe."
}