variable "resource_group" {}
variable "location" {}
variable "service_plan" {}
variable "web_app" {}
variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "ID of Log analytics resource"
}
variable "app_log_categories" {
  type        = list(string)
  default     = null
  description = "List of log categories. Defaults to all available."
}
variable "enable_audit_log_analytics" {
  type        = bool
  default     = false
  description = "Enab;e audit with Log analytics workspace solution"
}