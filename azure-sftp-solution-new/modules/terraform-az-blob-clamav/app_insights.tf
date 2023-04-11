resource "azurerm_application_insights" "logs" {
  count               = var.create_app_insight ? 1 : 0
  name                = "${var.resource_prefix}-triggers"
  location            = var.geo_location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}