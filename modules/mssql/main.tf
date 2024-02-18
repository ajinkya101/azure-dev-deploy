data "azurerm_resource_group" "rg" {
  name = var.resource_group
}

resource "random_password" "pass" {
  length           = 16
  min_upper        = 1
  min_lower        = 1
  special          = true
  override_special = "$%&"
}

locals {
  admin_password = random_password.pass.result
}

resource "azurerm_mssql_server" "sql" {
  for_each                     = var.mssql_server
  name                         = each.value["server_name"]
  location                     = data.azurerm_resource_group.rg.location
  resource_group_name          = data.azurerm_resource_group.rg.name
  administrator_login          = each.value["admin_username"]
  administrator_login_password = local.admin_password
  version                      = each.value["version"]
  minimum_tls_version          = each.value["minimum_tls_version"]
  tags                         = data.azurerm_resource_group.rg.tags

  lifecycle {
    ignore_changes = [administrator_login_password]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_database" "sqldb" {
  for_each                    = var.mssql_server
  name                        = each.value["sql_db_name"]
  server_id                   = azurerm_mssql_server.sql[each.key].id
  max_size_gb                 = each.value["max_size_gb"]
  sku_name                    = each.value["sku_name"]
  zone_redundant              = each.value["zone_redundant"]
  collation                   = each.value["collation"]
  create_mode                 = each.value["create_mode"]
  creation_source_database_id = each.value["creation_source_database_id"]
  restore_point_in_time       = each.value["restore_point_in_time"]
  tags                        = data.azurerm_resource_group.rg.tags
  depends_on = [
    azurerm_mssql_server.sql
  ]
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  for_each               = { for k, v in var.mssql_server : k => v if var.enable_audit_log_analytics }
  server_id              = azurerm_mssql_server.sql[each.key].id
  log_monitoring_enabled = true
}

resource "azurerm_monitor_diagnostic_setting" "sqldiag" {
  for_each                   = { for k, v in var.mssql_server : k => v if var.enable_audit_log_analytics }
  name                       = "sql-diagnotic-setting"
  target_resource_id         = "${azurerm_mssql_server.sql[each.key].id}/databases/master"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.sql_log_categories

    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "diag_settings_app" {
  for_each                   = { for k, v in var.mssql_server : k => v if var.enable_audit_log_analytics }

  name                       = "sql-diag-rule-01"
  target_resource_id         = azurerm_mssql_database.sqldb[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }
  enabled_log {
    category = "AutomaticTuning"
  }
  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }
  enabled_log {
    category = "QueryStoreWaitStatistics"
  }
  enabled_log {
    category = "Errors"
  }
  enabled_log {
    category = "DatabaseWaitStatistics"
  }
  enabled_log {
    category = "Timeouts"
  }
  enabled_log {
    category = "Deadlocks"
  }
}