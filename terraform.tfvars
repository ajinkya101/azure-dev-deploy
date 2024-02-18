rg_name              = "devrg01"
region               = "canadacentral"
storage_account_name = "stg737047"
network_rules = {
  bypass     = ["AzureServices"]
  ip_rules   = []
  subnet_ids = []
}
app_log_categories = ["AppServiceHTTPLogs", "AppServiceAppLogs"]
mssql_server = {
  "sql01" = {
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
tags = {
  "owner" = "master"
}