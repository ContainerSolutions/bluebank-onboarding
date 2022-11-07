package unittest

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	tfjson "github.com/hashicorp/terraform-json"
	"github.com/stretchr/testify/assert"
)

func TestServiceBus(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../../", "./test/terraform")
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		PlanFilePath: "./plan.out",
		// We could define our variables in golang code, but for now we will define them in terraform code
		Vars: nil,
		// We could also define variable files (.tfvars)
		VarFiles: nil,
	}
	// Checking if we can Plan the resource
	plan, err := terraform.InitAndPlanAndShowWithStructE(t, terraformOptions)
	if err != nil {
		t.Fatalf("tests failed during init and plan: %v", err)
	}
	// We check that our resource actually exists in the plan
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.this.azurerm_servicebus_namespace.this")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.this.azurerm_servicebus_namespace_network_rule_set.default_deny")
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.this.azurerm_servicebus_namespace_network_rule_set.allow_private_subnet")

	// We convert it to a golang structure (optional step)
	serviceBus := ServiceBus{}
	err = Convert(plan.ResourcePlannedValuesMap["module.this.azurerm_servicebus_namespace.this"], &serviceBus)
	assert.Nil(t, err)
	t.Logf("ServiceBusName: %v", serviceBus.Name)
	// We verify that LocalAuthEnabled is always false
	t.Run("MOCK-AZR-SVB-01", func(t *testing.T) {
		assert.False(t, serviceBus.LocalAuthEnabled)
	})

	defaultNetworkRuleSet := NetworkRuleSet{}

	// We convert it to a golang structure (optional step)
	err = Convert(plan.ResourcePlannedValuesMap["module.this.azurerm_servicebus_namespace_network_rule_set.default_deny"], &defaultNetworkRuleSet)
	assert.Nil(t, err)
	// We verify that PublicNetAccessEnabled is always false
	t.Run("MOCK-AZR-SVB-02", func(t *testing.T) {
		assert.False(t, defaultNetworkRuleSet.PublicNetAccessEnabled)
	})

	allowNetworkRuleSet := NetworkRuleSet{}
	err = Convert(plan.ResourcePlannedValuesMap["module.this.azurerm_servicebus_namespace_network_rule_set.allow_private_subnet"], &allowNetworkRuleSet)
	assert.Nil(t, err)
	t.Run("MOCK-AZR-SVB-02", func(t *testing.T) {
		assert.NotEmpty(t, allowNetworkRuleSet.NetworkRules)
		assert.Equal(t, allowNetworkRuleSet.IpRules[0], "10.1.0.0/24")
		assert.True(t, allowNetworkRuleSet.NetworkRules[0].IgnoreMissingVnetServiceEndpoint)
	})

}

// Helper function
func Convert(resource *tfjson.StateResource, structure interface{}) error {
	d, err := json.Marshal(resource.AttributeValues)
	if err != nil {
		return fmt.Errorf("tests failed during json convert: %w", err)
	}
	err = json.Unmarshal(d, structure)
	if err != nil {
		return fmt.Errorf("tests failed during json convert: %v", err)
	}
	return nil
}

// ServiceBus Helper structure
type ServiceBus struct {
	Name                   string `json:"name"`
	Location               string `json:"location"`
	LocalAuthEnabled       bool   `json:"local_auth_enabled"`
	PublicNetAccessEnabled bool   `json:"public_network_access_enabled"`
}

// NetworkRules struct
type NetworkRule struct {
	SubnetId                         string `json:"subnet_id"`
	IgnoreMissingVnetServiceEndpoint bool   `json:"ignore_missing_vnet_service_endpoint"`
}

// NetowrkRuleSet
type NetworkRuleSet struct {
	DefaultAction          string        `json:"default_action"`
	IpRules                []string      `json:"ip_rules,omitempty"`
	NetworkRules           []NetworkRule `json:"network_rules,omitempty"`
	PublicNetAccessEnabled bool          `json:"public_network_access_enabled"`
	TrustedServicesAllowed bool          `json:"trusted_services_allowed"`
}
