variable "resource_group" {}

variable "mssql_server" {
  type = map(object({
    server_name                 = string
    admin_username              = string
    version                     = string
    minimum_tls_version         = string
    sqlstorage_account_name     = string
    sqlstorage_account_tier     = string
    sqlstorage_replication_type = string
    sql_db_name                 = string
    max_size_gb                 = number
    sku_name                    = string
    zone_redundant              = bool
    collation                   = string
    create_mode                 = string
    creation_source_database_id = string
    restore_point_in_time       = string
  }))

  default = {
    "key" = {
      admin_username              = "sqldbadmin"
      collation                   = "SQL_Latin1_General_CP1_CI_AS"
      create_mode                 = "Default"
      creation_source_database_id = null
      max_size_gb                 = 4
      minimum_tls_version         = "1.2"
      restore_point_in_time       = null
      server_name                 = "sql-server-test29"
      sku_name                    = "BC_Gen5_2"
      sql_db_name                 = "sql-server-test29-db1"
      sqlstorage_account_name     = "sqlserverstr29"
      sqlstorage_account_tier     = "Standard"
      sqlstorage_replication_type = "LRS"
      version                     = "12.0"
      zone_redundant              = false
    }
  }
}

variable "sql_log_categories" {
  type        = list(string)
  default     = ["SQLSecurityAuditEvents"]
  description = "List of log categories. Defaults to all available."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "ID of Log analytics resource"
}

variable "enable_audit_log_analytics" {
  type        = bool
  default     = false
  description = "Enab;e audit with Log analytics workspace solution"
}