###################################################
# vSphere Variable Set
###################################################

resource "tfe_variable_set" "vsphere" {
  count = var.vsphere_config.enabled ? 1 : 0
  
  name         = "vsphere-platform-config"
  description  = "Platform configuration for vSphere deployments"
  organization = var.organization
  global       = false
}

# vSphere variables
resource "tfe_variable" "vsphere_datacenter" {
  count = var.vsphere_config.enabled ? 1 : 0
  
  key             = "vsphere_datacenter"
  value           = var.vsphere_config.datacenter
  category        = "terraform"
  description     = "vSphere datacenter"
  variable_set_id = tfe_variable_set.vsphere[0].id
  sensitive       = false
}

resource "tfe_variable" "vsphere_cluster" {
  count = var.vsphere_config.enabled ? 1 : 0
  
  key             = "vsphere_cluster"
  value           = var.vsphere_config.cluster
  category        = "terraform"
  description     = "vSphere cluster"
  variable_set_id = tfe_variable_set.vsphere[0].id
  sensitive       = false
}

resource "tfe_variable" "vsphere_datastore" {
  count = var.vsphere_config.enabled ? 1 : 0
  
  key             = "vsphere_datastore"
  value           = var.vsphere_config.datastore
  category        = "terraform"
  description     = "vSphere datastore"
  variable_set_id = tfe_variable_set.vsphere[0].id
  sensitive       = false
}

resource "tfe_variable" "vsphere_network" {
  count = var.vsphere_config.enabled ? 1 : 0
  
  key             = "vsphere_network"
  value           = var.vsphere_config.network
  category        = "terraform"
  description     = "vSphere network"
  variable_set_id = tfe_variable_set.vsphere[0].id
  sensitive       = false
}

resource "tfe_variable" "vsphere_folder" {
  count = var.vsphere_config.enabled ? 1 : 0
  
  key             = "vsphere_folder_path"
  value           = var.vsphere_config.folder_path
  category        = "terraform"
  description     = "vSphere VM folder path"
  variable_set_id = tfe_variable_set.vsphere[0].id
  sensitive       = false
}

###################################################
# AWS Variable Set
###################################################

resource "tfe_variable_set" "aws" {
  count = var.aws_config.enabled ? 1 : 0
  
  name         = "aws-platform-config"
  description  = "Platform configuration for AWS deployments"
  organization = var.organization
  global       = false
}

# AWS variables
resource "tfe_variable" "aws_region" {
  count = var.aws_config.enabled ? 1 : 0
  
  key             = "aws_region"
  value           = var.aws_config.region
  category        = "terraform"
  description     = "AWS region"
  variable_set_id = tfe_variable_set.aws[0].id
  sensitive       = false
}

resource "tfe_variable" "aws_account_id" {
  count = var.aws_config.enabled ? 1 : 0
  
  key             = "aws_account_id"
  value           = var.aws_config.account_id
  category        = "terraform"
  description     = "AWS account ID"
  variable_set_id = tfe_variable_set.aws[0].id
  sensitive       = false
}

resource "tfe_variable" "aws_vpc_id" {
  count = var.aws_config.enabled ? 1 : 0
  
  key             = "vpc_id"
  value           = var.aws_config.vpc_id
  category        = "terraform"
  description     = "AWS VPC ID"
  variable_set_id = tfe_variable_set.aws[0].id
  sensitive       = false
}

resource "tfe_variable" "aws_subnet_ids" {
  count = var.aws_config.enabled ? 1 : 0
  
  key             = "subnet_ids"
  value           = jsonencode(var.aws_config.subnet_ids)
  category        = "terraform"
  description     = "AWS subnet IDs"
  variable_set_id = tfe_variable_set.aws[0].id
  hcl             = true
  sensitive       = false
}

###################################################
# Azure Variable Set
###################################################

resource "tfe_variable_set" "azure" {
  count = var.azure_config.enabled ? 1 : 0
  
  name         = "azure-platform-config"
  description  = "Platform configuration for Azure deployments"
  organization = var.organization
  global       = false
}

# Azure variables
resource "tfe_variable" "azure_subscription_id" {
  count = var.azure_config.enabled ? 1 : 0
  
  key             = "azure_subscription_id"
  value           = var.azure_config.subscription_id
  category        = "terraform"
  description     = "Azure subscription ID"
  variable_set_id = tfe_variable_set.azure[0].id
  sensitive       = false
}

resource "tfe_variable" "azure_resource_group" {
  count = var.azure_config.enabled ? 1 : 0
  
  key             = "resource_group"
  value           = var.azure_config.resource_group
  category        = "terraform"
  description     = "Azure resource group"
  variable_set_id = tfe_variable_set.azure[0].id
  sensitive       = false
}

resource "tfe_variable" "azure_location" {
  count = var.azure_config.enabled ? 1 : 0
  
  key             = "location"
  value           = var.azure_config.location
  category        = "terraform"
  description     = "Azure location"
  variable_set_id = tfe_variable_set.azure[0].id
  sensitive       = false
}

resource "tfe_variable" "azure_virtual_network" {
  count = var.azure_config.enabled ? 1 : 0
  
  key             = "virtual_network"
  value           = var.azure_config.virtual_network
  category        = "terraform"
  description     = "Azure virtual network name"
  variable_set_id = tfe_variable_set.azure[0].id
  sensitive       = false
}

resource "tfe_variable" "azure_subnet_id" {
  count = var.azure_config.enabled ? 1 : 0
  
  key             = "subnet_id"
  value           = var.azure_config.subnet_id
  category        = "terraform"
  description     = "Azure subnet ID"
  variable_set_id = tfe_variable_set.azure[0].id
  sensitive       = false
} 