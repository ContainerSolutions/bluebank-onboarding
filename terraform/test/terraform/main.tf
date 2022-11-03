provider "azurerm" {
  features {}
}

module "this" {
    source = "../../"
    name = "test-servicebus"
    resource_group_name = "test"
    location = "westeurope"
    sku = "Standard"
    capacity = 0

}