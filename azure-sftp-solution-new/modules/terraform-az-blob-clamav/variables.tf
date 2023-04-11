variable "subscription_id" {
  description = "Azure subscription id eg xxxx-xxxxxx-xxxxxx-xxxx"
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name as deployment target"
  type        = string
}

variable "system_topic_resource_group_name" {
  description = "Resource Group name for Event Grid System Topic that matches the source resource group (Required when source storage account exists in different resource group than other clamav resources)"
  type        = string
  default     = ""
}

variable "geo_location" {
  description = "Azure location for the resources to be deployed to eg. uksouth"
  type        = string
}

variable "repository" {
  description = "Provide github repository url so we can easly identify which repo the resources have been deployed from"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to be added to every resource that will be created by this module (excluding storage accounts)"
  default     = "clamav"
  type        = string
}

variable "environment" {
  description = "Specify the environment for the deployed resources eg UAT, PROD, DEV"
  type        = string
}

variable "incoming_files_storage" {
  description = "Storage account for incoming files that need to be continously scanned by clamAV"
  type        = string
  default     = ""
}

variable "incoming_files_storage_tags" {
  description = "Addtional tags to be added to this storage account"
  type        = map(string)
  default     = {}
}

variable "virus_db_storage" {
  description = "Storage account for virus db files used by clamAV"
  type        = string
}

variable "virus_db_storage_tags" {
  description = "Additonal tags to be added to this storage account"
  type        = map(string)
  default     = {}
}

variable "function_storage" {
  description = "Storage account for function app triggers code"
  type        = string
}

variable "function_storage_tags" {
  description = "Additonal tags to be added to this storage account"
  type        = map(string)
  default     = {}
}

variable "create_output_clean_queue" {
  description = "Create output queue for 'clean files' so it can be used by other functionality (default is true)"
  type        = bool
  default     = true
}

variable "create_output_infected_queue" {
  description = "Create output queue for 'infected files' so it can be used by other functionality (default is true)"
  type        = bool
  default     = true
}

variable "experimental_deploy_runner" {
  description = "Run image build / deploy from terraform possible values (docker, limavm, none)"
  type        = string
  default     = "none"

  validation {
    condition     = contains(["docker", "limavm", "none"], var.experimental_deploy_runner)
    error_message = "Only (docker, limavm, none) are accepted. If 'none' is set you have to build/deploy container your self."
  }
}

variable "experimental_image_repo_ref" {
  description = "docker repository reference to be shallow cloned"
  type        = string
  default     = "main"
}

variable "create_incoming_sa" {
  description = "Set this to false if the storage account to be scanned already exists"
  type        = bool
  default     = true
}

variable "incoming_storage_conn_string" {
  description = "Connection string of the incoming storage account"
  type        = string
  default     = ""
}

variable "incoming_storage_id" {
  description = "Resource ID of the incoming storage account"
  type        = string
  default     = ""
}

variable "event_subject_filter" {
  description = "Specify a starting value for filtering the subject of each event(Only events with matching subjects get delivered)"
  type        = string
  default     = ""
}

variable "create_app_insight" {
  description = "Set this to false if the Application Insights component already exists"
  type        = bool
  default     = true
}

variable "appinsights_instrumentationkey" {
  description = "The instrumentation key for Application Insights"
  type        = string
  default     = ""
}

variable "appinsights_conn_string" {
  description = "The connection string for Application Insights"
  type        = string
  default     = ""
}

variable "function_app_tags" {
  description = "Tags to be added to the function app"
  type        = map(string)
  default     = {}
}

variable "scanner_container_memory" {
  description = "Memory required for the clamav scanner container in GB"
  type        = string
  default     = "1.5"
}

variable "create_eventgrid_system_topic" {
  description = "Set this to false if there is an existing system topic for the given source"
  type        = bool
  default     = true
}

variable "eventgrid_system_topic_name" {
  description = "The System Topic where the Event Subscription should be created in"
  type        = string
  default     = ""
}

// OUTPUTS

output "servicebus_namespace" {
  value = azurerm_servicebus_namespace.event_queues.name
}

output "servicebus_conn_string" {
  value = azurerm_servicebus_namespace.event_queues.default_primary_connection_string
}

output "servicebus_id" {
  value = azurerm_servicebus_namespace.event_queues.id
}

output "incoming_queue" {
  value = azurerm_servicebus_queue.incoming.name
}

output "output_clean_queue" {
  value = length(azurerm_servicebus_queue.clean) > 0 ? azurerm_servicebus_queue.clean.0.name : ""
}

output "output_infected_queue" {
  value = length(azurerm_servicebus_queue.infected) > 0 ? azurerm_servicebus_queue.infected.0.name : ""
}

output "update_container_group_name" {
  value = azurerm_container_group.clamav_update.name
}

output "incoming_storage_account_name" {
  value = length(azurerm_storage_account.incoming) > 0 ? azurerm_storage_account.incoming.0.name : ""
}

output "incoming_storage_account_conn_string" {
  value = length(azurerm_storage_account.incoming) > 0 ? azurerm_storage_account.incoming.0.primary_connection_string : ""
}

output "clamav_trigger_functionapp_id" {
  value = azurerm_function_app.clamav_triggers.id
}