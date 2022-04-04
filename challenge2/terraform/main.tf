# Terraform On Azure :: Challenge 2   (*HashiCorp Digital 2020*)
# 22/06/2020
# Deploy sample app Azure App Services in a standalone manner and db instances on Azure SQL and Azure Container instances.

# Configure the AzureRM provider (using v2.1)
provider "azurerm" {
  version         = "~>2.14.0"
  subscription_id = var.subscription_id
  features {}
}

# Provision a resource group to hold all Azure resources
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

# Provision the App Service plan to host the App Service web app
resource "azurerm_app_service_plan" "main" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Provision the Azure App Service to host the main web site
resource "azurerm_app_service" "main" {
  name                = "${var.prefix}-appservice"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  site_config {
    always_on = true
    scm_type  = "ExternalGit"
    //scm_type  = "LocalGit"
    default_documents = [
      "Default.htm",
      "Default.html",
      "hostingstart.html"
    ]
  }
  
#   provisioner "local-exec" {
#    command = "git remote set-url azure ${var.repo_url} && git pull && git push azure master"
#   }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "10.15.2"
    "ApiUrl"                       = "/api/v1"
    "ApiUrlShoppingCart"           = "/api/v1"
    "MongoConnectionString"        = "mongodb://${var.db_mongo_login_name}:${var.db_mongo_login_passwd}@${azurerm_container_group.main.fqdn}:27017"
    "SqlConnectionString"          = "Server=tcp:${azurerm_sql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${var.db_azuresql_database_name};Persist Security Info=False;User ID=${var.db_azuresql_admin_login_name};Password=${var.db_azuresql_admin_login_passwd};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    "productImagesUrl"             = "https://raw.githubusercontent.com/microsoft/TailwindTraders-Backend/master/Deploy/tailwindtraders-images/product-detail"
    "Personalizer_ApiKey"         = ""
    "Personalizer_Endpoint"       = ""
  }
  https_only = true
}

# resource "azurerm_app_service_source_control" "main" {
#   app_service_id        = "${azurerm_app_service.main.id}"
#   repo_url              = "https://github.com/nithinmohantk/AzureEats-Website.git"
#   is_manual_integration = true
#   branch                = "master"
# }

resource "null_resource" "appserviceci" {
  triggers = {
    version = "0.0.1"
  }
  provisioner "local-exec" {
    command = "az webapp deployment source config --branch ${var.branch} --manual-integration --name ${azurerm_app_service.main.name} --repo-url ${var.repo_url} --resource-group ${azurerm_resource_group.main.name}"
  }
  depends_on = [
    azurerm_app_service.main
  ]
}

resource "azurerm_storage_account" "main" {
  name                     = substr(replace("${var.prefix}store", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "main" {
  name                 = "mongodata"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 50
}


## 1. Azure SQL instance
resource "azurerm_sql_server" "sql_server" {
  name                         = "${var.prefix}-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.db_azuresql_admin_login_name
  administrator_login_password = var.db_azuresql_admin_login_passwd
  tags = {
    environment = "dev"
  }
}

resource "azurerm_sql_firewall_rule" "sql_firewall" {
  name                = "AllowAccessToAzure"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_sql_server.sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_database" "sql_db" {
  name                             = var.db_azuresql_database_name
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  server_name                      = azurerm_sql_server.sql_server.name
  collation                        = var.db_azuresql_database_collation
  edition                          = var.db_azuresql_database_type
  requested_service_objective_name = var.db_azuresql_database_service_scaling_objective
  tags = {
    environment = "dev"
  }
}

## Provision the Azure Container Resources
##1. MongoDb Instance
resource "azurerm_container_group" "main" {
  name                = "${var.prefix}-continst"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  ip_address_type     = "public"
  dns_name_label      = "${var.prefix}-continst"
  os_type             = "linux"

  container {
    name   = "mongo"
    image  = "mongo"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 27017
      protocol = "TCP"
    }

    volume {
      name       = "database"
      mount_path = "/data/mongoaz"
      read_only  = false
      share_name = azurerm_storage_share.main.name

      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
    }

    environment_variables = {
      MONGO_INITDB_DATABASE = var.db_mongo_database_name
      MONGODB_USER          = var.db_mongo_login_name
      MONGODB_PASS          = var.db_mongo_login_passwd
    }

    commands = ["mongod", "--dbpath=/data/mongoaz", "--bind_ip_all", "--auth"]
  }

  tags = {
    environment = "dev"
  }

}