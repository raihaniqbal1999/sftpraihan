###############################################
# This monitor is responsible for starting
# ClamAV container in scan mode as soon
# as new blob notification appear in servicebus
###############################################

data "azurerm_function_app_host_keys" "triggers" {
  name                = azurerm_function_app.clamav_triggers.name
  resource_group_name = var.resource_group_name
}

# monitor the incoming queue for new notification
resource "azurerm_monitor_action_group" "new_notifications" {
  name                = "StartScanner"
  resource_group_name = var.resource_group_name
  short_name          = "StartScanner"


  azure_function_receiver {
    function_app_resource_id = azurerm_function_app.clamav_triggers.id
    function_name            = "clamav-scanner-trigger"
    http_trigger_url         = "https://${azurerm_function_app.clamav_triggers.default_hostname}/api/clamav-scanner-trigger?code=${data.azurerm_function_app_host_keys.triggers.default_function_key}"
    name                     = "start-clamav-db-update"
    use_common_alert_schema  = false
  }
}

# alert triggers the scanner function that in turn starts the clamAV container
resource "azurerm_monitor_metric_alert" "sb_queue" {
  name                = "NewBlobCreatedNotifications"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_servicebus_namespace.event_queues.id]
  description         = "NewBlobCreatedNotifications triggers alert if we have > 0 notifications"
  window_size         = "PT1M"
  auto_mitigate       = false

  criteria {
    metric_namespace = "Microsoft.ServiceBus/namespaces"
    metric_name      = "Messages"
    aggregation      = "Average" // or total ???
    operator         = "GreaterThan"
    threshold        = 0

    dimension {
      name     = "EntityName"
      operator = "Include"
      values   = [azurerm_servicebus_queue.incoming.name]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.new_notifications.id
  }
}