provider "azurerm" {
  features {}
}

module "this" {
  source              = "../../"
  name                = "test-servicebus"
  resource_group_name = "test"
  location            = "westeurope"
  sku                 = "Premium"
  capacity            = 0
  ip_rules            = ["10.1.0.0/24"]

  network_rules = [
    {
      subnet_id                            = "/subscriptions/{Subscription ID}/resourceGroups/MyResourceGroup/providers/Microsoft.Network/virtualNetworks/MyNet/subnets/MySubnet"
      ignore_missing_vnet_service_endpoint = true
    }
  ]

  customer_managed_key = [ {
    identity_id = "/subscriptions/{Subscription ID}/resourceGroups/MyResourceGroup/providers/Microsoft.ManagedIdentity/userAssignedIdentities/MyManagedIdentity"
    infrastructure_encryption_enabled = true
    key_vault_key_id = "https://my-keyvault.vault.net/key/foobar/123094850"
  } ]

}