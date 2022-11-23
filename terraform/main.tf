terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_servicebus_namespace" "this" {
    name                = var.name
    location            = var.location
    resource_group_name = var.resource_group_name
    sku                 = var.sku
    dynamic "identity" {
        for_each = var.identity
        content {
            type = identity.value.type
            identity_ids = identity.value.identity_ids
        }
    }
    capacity = var.capacity
    dynamic "customer_managed_key" {
        for_each = var.customer_managed_key
        content {
            key_vault_key_id = customer_managed_key.value.key_vault_key_id
            identity_id = customer_managed_key.value.identity_id
            infrastructure_encryption_enabled = customer_managed_key.value.infrastructure_encryption_enabled
        }
    }
    
    local_auth_enabled = false
    public_network_access_enabled = false
    minimum_tls_version = var.minimum_tls_version
    zone_redundant = var.zone_redundant
    tags = var.tags
}

# Ruleset to deny public access (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_network_rule_set)
resource "azurerm_servicebus_namespace_network_rule_set" "deny" {
  namespace_id = azurerm_servicebus_namespace.this.id

  default_action = "Deny"
  public_network_access_enabled = false
}
