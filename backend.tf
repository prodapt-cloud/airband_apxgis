terraform {
  backend "azurerm" {
    storage_account_name = "terraformdevstate"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}