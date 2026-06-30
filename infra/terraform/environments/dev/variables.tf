variable "environment_config" {
  type = object({
    project_name   = string
    environment    = string
    location       = string
    location_short = string
    owner          = string
    repository     = string
  })

  default = {
    project_name   = "devops-lab"
    environment    = "dev"
    location       = "westeurope"
    location_short = "weu"
    owner          = "JVReich"
    repository     = "github.com/JVReich/devops-lab-launcher"
  }
}

variable "virtual_network" {
  type = object({
    address_space       = list(string)
    aks_subnet_prefixes = list(string)
  })

  default = {
    address_space       = ["10.10.0.0/16"]
    aks_subnet_prefixes = ["10.10.1.0/24"]
  }
}

