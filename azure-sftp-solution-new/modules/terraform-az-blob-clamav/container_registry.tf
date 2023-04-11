resource "azurerm_container_registry" "clamav" {
  name                = "${var.resource_prefix}dockerclamavazurerai"
  resource_group_name = var.resource_group_name
  location            = var.geo_location
  sku                 = "Basic"
  admin_enabled       = true

  tags = merge(
    local.tags,
    {
      ImageSource = "https://github.com/KPMG-UK/docker-clamav-azure"
    }
  )
}