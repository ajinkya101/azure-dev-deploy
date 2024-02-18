variable "rg_name" {
  description = "Name of resource groups"
  type        = string
}

variable "region" {
  description = "Location of Resource groups"
  type        = string
}

variable "storage_account_name" {
  type        = string
  description = "Specifies the name of the storage account"
}

variable "network_rules" {
  description = "Network rules restricing access to the storage account."
  type        = object({ bypass = list(string), ip_rules = list(string), subnet_ids = list(string) })
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}