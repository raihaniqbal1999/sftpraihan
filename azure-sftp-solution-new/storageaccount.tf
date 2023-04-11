// initial storage container
resource "azurerm_storage_account" "blob_storage" {
  name                     = "${var.project_name}${lower(var.environment)}storage"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "GRS"
  is_hns_enabled           = true
  sftp_enabled             = true

  blob_properties {
    delete_retention_policy {
      days = 180
    }
    container_delete_retention_policy {
      days = 180
    }
  }
}

resource "azurerm_storage_container" "preclam_storage_container" {
  name                  = "${var.project_name}${lower(var.environment)}preclam"
  storage_account_name  = azurerm_storage_account.blob_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "post_clam_container_pass" {
  name                  = "${var.project_name}${lower(var.environment)}postclampass"
  storage_account_name  = azurerm_storage_account.blob_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "post_clam_container_fail" {
  name                  = "${var.project_name}${lower(var.environment)}postclamfail"
  storage_account_name  = azurerm_storage_account.blob_storage.name
  container_access_type = "private"
}