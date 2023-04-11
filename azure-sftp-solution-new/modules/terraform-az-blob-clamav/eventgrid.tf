#####################################################
# Event Grid is responsible for sending notifications
# to service bus on every created blob
#####################################################

resource "azurerm_eventgrid_system_topic" "blob_created" {
  count                  = var.create_eventgrid_system_topic ? 1 : 0
  name                   = "${var.resource_prefix}-blob-created"
  resource_group_name    = length(var.system_topic_resource_group_name) > 0 ? var.system_topic_resource_group_name : var.resource_group_name
  location               = var.geo_location
  source_arm_resource_id = var.create_incoming_sa ? azurerm_storage_account.incoming[0].id : var.incoming_storage_id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  tags = local.tags
}

resource "azurerm_eventgrid_system_topic_event_subscription" "servicebus" {
  name                          = "${var.resource_prefix}-blob-created"
  system_topic                  = var.create_eventgrid_system_topic ? azurerm_eventgrid_system_topic.blob_created[0].name : var.eventgrid_system_topic_name
  resource_group_name           = length(var.system_topic_resource_group_name) > 0 ? var.system_topic_resource_group_name : var.resource_group_name
  service_bus_queue_endpoint_id = azurerm_servicebus_queue.incoming.id

  included_event_types = [
    "Microsoft.Storage.BlobCreated"
  ]

  subject_filter {
    subject_begins_with = var.event_subject_filter
  }
}