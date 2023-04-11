resource "azurerm_storage_account" "func_storage" {
  name                     = var.function_storage
  resource_group_name      = var.resource_group_name
  location                 = var.geo_location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  enable_https_traffic_only = true

  access_tier     = "Hot"
  min_tls_version = "TLS1_2"
  blob_properties {
    delete_retention_policy {
      days = 90
    }
    container_delete_retention_policy {
      days = 90
    }
  }

  //allow_blob_public_access = false //error
  tags = merge(
    local.tags, var.function_storage_tags
  )
}

resource "azurerm_app_service_plan" "triggers" {
  name                = "${var.resource_prefix}-func-triggers-sp"
  location            = var.geo_location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "clamav_triggers" {
  depends_on = [
    azurerm_container_group.clamav_scanner,
    azurerm_container_group.clamav_update

  ]
  name                       = "${var.resource_prefix}-triggers"
  location                   = var.geo_location
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = azurerm_app_service_plan.triggers.id
  storage_account_name       = azurerm_storage_account.func_storage.name
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  os_type                    = "linux"
  https_only                 = true
  //use_32_bit_worker_process  = true
  version = "~3"

  site_config {
    linux_fx_version = "PYTHON|3.9"
    ftps_state       = "Disabled"
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME              = "python"
    APPINSIGHTS_INSTRUMENTATIONKEY        = var.create_app_insight ? azurerm_application_insights.logs[0].instrumentation_key : var.appinsights_instrumentationkey
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.create_app_insight ? azurerm_application_insights.logs[0].connection_string : var.appinsights_conn_string
    SUBSCRIPTION_ID                       = var.subscription_id
    RESOURCE_GROUP                        = var.resource_group_name
    UPDATE_CONTAINER_GROUP                = azurerm_container_group.clamav_update.name
    SCANNER_CONTAINER_GROUP               = azurerm_container_group.clamav_scanner.name
  }

  lifecycle {
    ignore_changes = [
      //app_settings.WEBSITE_RUN_FROM_PACKAGE
      tags
    ]
  }
  tags = var.function_app_tags
}

resource "azurerm_role_definition" "aci_triggers" {
  name        = "${var.resource_prefix}-clamav-aci-triggers"
  scope       = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  description = "This role is used by clamav function triggers to start aci containers"

  permissions {
    // limit those permission to minimum required set
    actions = [
      "Microsoft.ContainerInstance/containerGroups/start/action",
      "Microsoft.ContainerInstance/containerGroups/read"
    ]
    not_actions = []
  }
}

resource "azurerm_role_assignment" "function_role" {
  depends_on = [
    azurerm_function_app.clamav_triggers
  ]
  scope              = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_id = azurerm_role_definition.aci_triggers.role_definition_resource_id
  principal_id       = azurerm_function_app.clamav_triggers.identity.0.principal_id
}

// wait for functionapp to be fully accessible after deplyment
resource "time_sleep" "wait_for_functionapp" {
  depends_on = [azurerm_function_app.clamav_triggers]

  //sleep
  create_duration = "30s"
}

resource "null_resource" "deploy_func_triggers" {
  depends_on = [
    time_sleep.wait_for_functionapp,
    azurerm_container_group.clamav_scanner,
    azurerm_container_group.clamav_update
  ]

  // we could zip the dir and then do the sha, but this way we dont have to create unnecessary files
  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset("${path.module}/functions", "**") : filesha1("${path.module}/functions/${f}")]))
  }

  // for this to work while on KPMG network you have to get off VPN or set proxy
  provisioner "local-exec" {
    command = "cd ${path.module}/functions; func azure functionapp publish ${azurerm_function_app.clamav_triggers.name} --python; cd ${path.root}"
  }
}