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
  # az service bus namespace has to be premium to provide
  # encryption of data at rest with az storage service encryption
  sku                 = "Premium"
  dynamic "identity" {
    for_each = var.identity
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
  capacity = var.capacity
  # customer managed key could be provided as a resource, but for this exercise, we'll read 
  # from values file and check that infrastructure encryption has been enabled.
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key
    content {
      key_vault_key_id                  = customer_managed_key.value.key_vault_key_id
      identity_id                       = customer_managed_key.value.identity_id
      infrastructure_encryption_enabled = true
    }
  }

  local_auth_enabled            = false
  public_network_access_enabled = false
  minimum_tls_version           = var.minimum_tls_version
  zone_redundant                = var.zone_redundant
  tags                          = var.tags
}

# Default deny ruleset
resource "azurerm_servicebus_namespace_network_rule_set" "default_deny" {
  namespace_id = azurerm_servicebus_namespace.this.id

  default_action                = "Deny"
  public_network_access_enabled = false
  trusted_services_allowed      = var.trusted_services_allowed
}

# ruleset to deny public access but allow private subnets

resource "azurerm_servicebus_namespace_network_rule_set" "allow_private_subnet" {
  namespace_id = azurerm_servicebus_namespace.this.id

  default_action                = var.default_action
  public_network_access_enabled = false


  trusted_services_allowed = var.trusted_services_allowed

  ip_rules = var.ip_rules

  dynamic "network_rules" {
    for_each = var.network_rules
    content {
      subnet_id                            = network_rules.value.subnet_id
      ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint

    }
  }
}