variable "location" {
  type        = string
  description = "Azure region for the Terraform state resources."
  default     = "israelcentral"
}

variable "location_short" {
  type        = string
  description = "Short region code."
  default     = "ilc"
}

variable "project_name" {
  type        = string
  description = "Project name."
  default     = "devops-lab"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to bootstrap resources."
  default = {
    Project     = "devops-lab"
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
    Owner       = "JVReich"
    Purpose     = "Terraform remote state"
  }
}