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

resource "azurerm_policy_set_definition" "mock_ce_multi_svb" {
  name         = "mock-ce-multi-svb"
  policy_type  = "Custom"
  display_name = "mock-ce-multi-svb"

  parameters = ""

  policy_definition_reference {
    reference_id = "mock-ce-svb-deny-local-auth"
    ## Azure Service Bus namespaces should have local authentication methods disabled
    ## https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fcfb11c26-f069-4c14-8e36-56c394dae5af2
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cfb11c26-f069-4c14-8e36-56c394dae5af"
    parameter_values     = <<VALUE
    {
      "effect": {"value": "Deny"}
    }
    VALUE
  }
}