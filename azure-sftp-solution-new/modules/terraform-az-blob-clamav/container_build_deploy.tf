// wait for registry to be fully accessible after deplyment
resource "time_sleep" "wait_30_seconds" {
  depends_on = [azurerm_container_registry.clamav]

  //sleep
  create_duration = "30s"
}

resource "null_resource" "deploy_container" {
  // manual deploy (none) or automated (docker / limavm)
  count = var.experimental_deploy_runner == "none" ? 0 : 1

  depends_on = [
    time_sleep.wait_30_seconds
  ]

  triggers = {
    only_if_refs_change = var.experimental_image_repo_ref
  }

  // for this to work while on KPMG network you have to get off VPN or set proxy
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/${var.experimental_deploy_runner}_deploy.sh"

    environment = {
      GIT_REF       = var.experimental_image_repo_ref
      ROOT_PATH     = path.root
      CONT_REG_NAME = azurerm_container_registry.clamav.name
    }
  }
}