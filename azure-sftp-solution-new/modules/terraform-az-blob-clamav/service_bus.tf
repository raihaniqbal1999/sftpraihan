####################################
# ServiceBus is used as tracking for 
# all blob created notifications and 
# feed for scanner
####################################

resource "azurerm_servicebus_namespace" "event_queues" {
  name                = "${var.resource_prefix}-events-rai"
  location            = var.geo_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_servicebus_queue" "incoming" {
  name         = "${var.resource_prefix}-input-queue"
  namespace_id = azurerm_servicebus_namespace.event_queues.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "clean" {
  count        = var.create_output_clean_queue ? 1 : 0
  name         = "${var.resource_prefix}-clean-output-queue" // aka clean files queue
  namespace_id = azurerm_servicebus_namespace.event_queues.id

  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "infected" {
  count        = var.create_output_infected_queue ? 1 : 0
  name         = "${var.resource_prefix}-infected-output-queue" // aka infected files queue
  namespace_id = azurerm_servicebus_namespace.event_queues.id

  enable_partitioning = true
}