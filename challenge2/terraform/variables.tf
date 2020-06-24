variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "mytoa3"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "westeurope"
}

variable "subscription_id" {
  description = "Azure Subscription ID to be used for billing"
  default = "f6b4ae2b-1c5e-4530-9de0-2669440f07e5"
}

variable "branch" {
  description = "The branch name of the repository"
  default     = "master"
}

variable "repo_url" {
  description = "Repository url to pull the latest source from"
  default     = "https://github.com/nithinmohantk/AzureEats-Website.git"
}

variable "db_azuresql_database_collation" {
  default     = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  description = "SQL collation to be used."
}

variable "db_azuresql_database_type" {
  default     = "Standard"
  description = "Edition of the Azure SQL database to be used for provisioning."
}

variable "db_azuresql_database_name" {
  default     = "azure-eats-db"
  description = "Initial database name on the server."
}

variable "db_azuresql_admin_login_name" {
  default     = "sqladmin"
  description = "DB Login name for the sql server administrator."
}

variable "db_azuresql_admin_login_passwd" {
  default     = "Developer@123#"
  description = "DB Password for the sql server administrator."
}

variable "db_azuresql_database_service_scaling_objective" {
  default     = "S1"
  description = "Service scaling objective for the Azure SQL database provisioning."
}

variable "db_mongo_database_name" {
  default     = "user"
  description = "DB name for the MongoDb."
}

variable "db_mongo_login_name" {
  default     = "azure-eats-db"
  description = "DB Login name for the MongoDb."
}

variable "db_mongo_login_passwd" {
  default     = "Developer@123#"
  description = "DB Password for the MongoDb."
}

