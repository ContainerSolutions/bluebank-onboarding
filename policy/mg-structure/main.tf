terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "this" {}

resource "azurerm_resource_group" "scope" {
  name     = "policy_mock_scope"
  location = "westeurope"
}

resource "azurerm_resource_group_policy_assignment" "mock_svb_assignment" {
  name                 = "mock-svb-assignment"
  resource_group_id    = azurerm_resource_group.scope.id
  policy_definition_id = "/subscriptions/${data.azurerm_subscription.this.subscription_id}/providers/Microsoft.Authorization/policySetDefinitions/mock-ce-multi-svb"
  parameters = ""
}