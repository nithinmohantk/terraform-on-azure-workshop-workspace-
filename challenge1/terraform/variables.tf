variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "mytoa"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "westeurope"
}

variable "subscription_id" {
  description = "Azure Subscription ID to be used for billing"
  default = "f6b4ae2b-1c5e-4530-9de0-2669440f07e5"
}