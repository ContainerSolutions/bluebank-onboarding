variable "name" {
    type = string
}
variable "location" { 
    type = string
}
variable "resource_group_name" {
    type = string
}
variable "sku" {
    type = string
}
variable "capacity" {
    type = string
}
variable "public_network_access_enabled" {
    type = bool
    default = true
}
variable "minimum_tls_version" {
    type = string
    default = "1.0"
}
variable "zone_redundant" { 
    type = bool
    default = false
}
variable "customer_managed_key" {
    type = list(object({
        key_vault_key_id = string
        identity_id = string
        infrastructure_encryption_enabled = bool
    }))
    validation {
        condition = length(var.customer_managed_key) < 2
        error_message = "Only one customer managed key can be configured."
    }
    default = []
}
variable "identity" {
    type = list(object({
        type = string
        identity_ids = list(string)
    }))
    validation {
        condition = length(var.identity) < 2
        error_message = "Only one identity can be configured."
    }
    default = []
}
variable tags {
    type = map(string)
    default = {}
}