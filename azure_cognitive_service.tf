provider "azurerm" {
version = "=2.0.0"
### Fix for Error: "features": required field is not set
features {}
skip_provider_registration = true
}

# resource "azurerm_resource_group" "imagelense" {
#   name     = "imagelense"
#   location = "East US"
# }

resource "azurerm_cognitive_account" "imagelense" {
  name                = "imagelense-account"
  location            =  "West US" ##azurerm_resource_group.imagelense.location
  resource_group_name = var.azure_resource_group ###azurerm_resource_group.imagelense.name
  kind                = "ComputerVision"
  sku_name = "S1"

}