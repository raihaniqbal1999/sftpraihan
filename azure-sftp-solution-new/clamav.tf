

module "clamav_scanner" {
  source = "./modules/terraform-az-blob-clamav"

  repository                    = var.repository
  environment                   = var.environment
  resource_prefix               = "sftp"
  resource_group_name           = azurerm_resource_group.resource_group.name
  subscription_id               = var.subscription_id
  geo_location                  = azurerm_resource_group.resource_group.location
  function_storage              = "${var.project_name}${lower(var.environment)}funcsa"
  incoming_files_storage        = azurerm_storage_account.blob_storage.name
  incoming_storage_conn_string  = azurerm_storage_account.blob_storage.primary_connection_string
  virus_db_storage              = "${var.project_name}${lower(var.environment)}virusdb"
  experimental_deploy_runner    = "docker"
  experimental_image_repo_ref   = "main"
  create_incoming_sa            = false
  incoming_storage_id           = azurerm_storage_account.blob_storage.id
  event_subject_filter          = ""
  create_app_insight            = "true"
  function_app_tags             = {}
  scanner_container_memory      = "1.5"
  create_eventgrid_system_topic = "true"
  eventgrid_system_topic_name   = ""
}