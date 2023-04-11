########################################
# The incoming storage account
# is the scanned storage. Each new blob
# created event will trigger clamav scan
########################################

resource "azurerm_storage_account" "incoming" {
  count                         = var.create_incoming_sa ? 1 : 0
  name                          = var.incoming_files_storage
  resource_group_name           = var.resource_group_name
  location                      = var.geo_location
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  public_network_access_enabled = false

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
  //allow_blob_public_access = false


  tags = merge(
    local.tags, var.incoming_files_storage_tags
  )
}

#######################################
# virusdb storage is used only
# for storing updated virus definitions
# database for clamav, do not store any
# other files here
#######################################



resource "azurerm_storage_account" "virus_db" {
  name                          = var.virus_db_storage
  resource_group_name           = var.resource_group_name
  location                      = var.geo_location
  account_kind                  = "StorageV2"
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  public_network_access_enabled = true
  enable_https_traffic_only     = true

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

  tags = merge(
    local.tags, var.virus_db_storage_tags
  )
}

resource "azurerm_storage_container" "virus_db" {
  name                  = "local-virus-db"
  storage_account_name  = azurerm_storage_account.virus_db.name
  container_access_type = "private"
}

