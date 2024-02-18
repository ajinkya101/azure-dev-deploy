output "service_plan_id" {
  description = "ID of service plam"
  value       = azurerm_service_plan.service_plan
}

output "app_id" {
  value = azurerm_windows_web_app.web_app.id
}