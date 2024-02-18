output "sql_server_name" {
  value = [for s in azurerm_mssql_server.sql : s.name]
}

output "sql_server_id" {
  value = [for s in azurerm_mssql_server.sql : s.id]
}

output "sql_server_id_name" {
  value = { for s in azurerm_mssql_server.sql : s.name => s.id }
}

output "admin_password" {
  value = random_password.pass.result
}

output "sql_db_id" {
  value = { for s in azurerm_mssql_database.sqldb : s.name => s.id }
}