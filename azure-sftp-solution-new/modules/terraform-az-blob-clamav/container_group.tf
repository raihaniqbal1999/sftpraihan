#######################################
# This the the main scanner container
# It is started as soon as we have some
# messages ready for processing
#######################################
resource "azurerm_container_group" "clamav_scanner" {
  depends_on          = [null_resource.deploy_container]
  name                = "${var.resource_prefix}-clamav-scanner"
  location            = var.geo_location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "docker-clamav-azure"
    image  = "${azurerm_container_registry.clamav.name}.azurecr.io/docker-clamav-azure:latest"
    cpu    = "2.0"
    memory = var.scanner_container_memory

    commands = [
      "./scanner",
      "-mode",
      "scan",
      "-debug",
    ]

    ports {
      port     = 443
      protocol = "TCP"
    }

    secure_environment_variables = {
      SERVICE_BUS_CONNECTION_STRING      = azurerm_servicebus_namespace.event_queues.default_primary_connection_string
      INCOMING_STORAGE_CONNECTION_STRING = var.create_incoming_sa ? azurerm_storage_account.incoming[0].primary_connection_string : var.incoming_storage_conn_string
      VIRUS_DB_STORAGE_CONNECTION_STRING = azurerm_storage_account.virus_db.primary_connection_string
      INCOMING_FILES_QUEUE               = azurerm_servicebus_queue.incoming.name
      VIRUS_DB_CONTAINER_NAME            = azurerm_storage_container.virus_db.name
      CLEAN_FILES_QUEUE                  = var.create_output_clean_queue ? azurerm_servicebus_queue.clean[0].name : ""
      INFECTED_FILES_QUEUE               = var.create_output_infected_queue ? azurerm_servicebus_queue.infected[0].name : ""
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.clamav.login_server
    username = azurerm_container_registry.clamav.admin_username
    password = azurerm_container_registry.clamav.admin_password
  }



  tags = merge(
    local.tags,
    {
      ImageSource = "https://github.com/KPMG-UK/docker-clamav-azure"
    }
  )
}

############################################
# This container is run on schedule
# It should run every X hours no less then 3
# If you run update too frequently your ip
# may be blocked on clamav cdn
############################################
resource "azurerm_container_group" "clamav_update" {
  depends_on          = [null_resource.deploy_container]
  name                = "${var.resource_prefix}-clamav-update"
  location            = var.geo_location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "docker-clamav-azure"
    image  = "${azurerm_container_registry.clamav.name}.azurecr.io/docker-clamav-azure:latest"
    cpu    = "2.0"
    memory = "1.5"

    commands = [
      "./scanner",
      "-mode",
      "update",
      "-debug",
    ]

    ports {
      port     = 443
      protocol = "TCP"
    }

    secure_environment_variables = {
      VIRUS_DB_STORAGE_CONNECTION_STRING = azurerm_storage_account.virus_db.primary_connection_string
      VIRUS_DB_CONTAINER_NAME            = azurerm_storage_container.virus_db.name
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.clamav.login_server
    username = azurerm_container_registry.clamav.admin_username
    password = azurerm_container_registry.clamav.admin_password
  }



  tags = merge(
    local.tags,
    {
      ImageSource = "https://github.com/KPMG-UK/docker-clamav-azure"
    }
  )
}