resource "azurerm_storage_account" "terraform_state" {
  name                     = var.storage_account_name
  resource_group_name       = var.resource_group
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
  }

  tags = "dev"
}

resource "azurerm_storage_container" "terraform_state_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}
