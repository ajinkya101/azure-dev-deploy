resource "azurerm_service_plan" "service_plan" {
  name                = var.service_plan
  resource_group_name = var.resource_group
  location            = var.location
  sku_name            = "P1v2"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "web_app" {
  name                = var.web_app
  resource_group_name = var.resource_group
  location            = var.location
  service_plan_id     = azurerm_service_plan.service_plan.id
  site_config {}
}

# resource "azurerm_monitor_diagnostic_setting" "diag_settings_app" {
#   count                      = var.enable_audit_log_analytics == true ? 1 : 0
#   name                       = "app-diag-rule"
#   target_resource_id         = azurerm_windows_web_app.web_app.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id

#   dynamic "enabled_log" {
#     for_each = var.app_log_categories

#     content {
#       category = enabled_log.value
#     }
#   }
# }
