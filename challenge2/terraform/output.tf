output "appServiceHostUrl" {
  value = azurerm_app_service.main.default_site_hostname
}

output "dbMongoHost" {
  value = azurerm_container_group.main.fqdn
}

output "dbSqlServerFqdn" {
    value = azurerm_sql_server.sql_server.fully_qualified_domain_name
}