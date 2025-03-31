# Variable Sets Module

This module creates and manages variable sets for different cloud platforms in Terraform Enterprise, making it easy to share platform-specific configurations across multiple workspaces and projects.

## Overview

The Variable Sets module:

- Creates platform-specific variable sets for AWS, Azure, and vSphere
- Populates variable sets with appropriate variables for each platform
- Organizes variables in a logical structure that can be applied to workspaces
- Supports global variable sets that can be applied across the organization

## Usage

```hcl
module "platform_varsets" {
  source       = "../modules/variable-sets"
  organization = "my-tfe-org"
  
  # AWS Configuration
  aws_config = {
    enabled     = true
    region      = "ap-southeast-2"
    account_id  = "123456789012"
    vpc_id      = "vpc-abcdef123456"
    subnet_ids  = ["subnet-abc123", "subnet-def456"]
  }
  
  # Azure Configuration
  azure_config = {
    enabled         = true
    subscription_id = "00000000-0000-0000-0000-000000000000"
    resource_group  = "my-terraform-rg"
    location        = "australiaeast"
    virtual_network = "my-vnet"
    subnet_id       = "subnet-id-123"
  }
  
  # vSphere Configuration
  vsphere_config = {
    enabled     = true
    datacenter  = "dc-01"
    cluster     = "cluster-01"
    datastore   = "datastore-01"
    network     = "network-01"
    folder_path = "/vm/terraform-managed"
  }
}
```

## Platform-Specific Variables

Each platform variable set includes variables relevant to that cloud provider:

### AWS Variables
The AWS variable set includes:
- `AWS_REGION` - The AWS region for resource deployment
- `AWS_ACCOUNT_ID` - The AWS account ID
- `AWS_VPC_ID` - The VPC ID for networking
- `AWS_SUBNET_IDS` - A list of subnet IDs for resource placement
- `AWS_DEFAULT_TAGS` - Default tags for resources (customizable)

### Azure Variables
The Azure variable set includes:
- `ARM_SUBSCRIPTION_ID` - The Azure subscription ID
- `ARM_RESOURCE_GROUP` - Default resource group for resources
- `ARM_LOCATION` - The Azure location for resource deployment
- `ARM_VIRTUAL_NETWORK` - The virtual network for networking
- `ARM_SUBNET_ID` - The subnet ID for resource placement
- `ARM_DEFAULT_TAGS` - Default tags for resources (customizable)

### vSphere Variables
The vSphere variable set includes:
- `VSPHERE_DATACENTER` - The vSphere datacenter name
- `VSPHERE_CLUSTER` - The vSphere cluster for VM placement
- `VSPHERE_DATASTORE` - The datastore for VM storage
- `VSPHERE_NETWORK` - The network for VM network connections
- `VSPHERE_FOLDER` - The VM folder path for organization
- `VSPHERE_TEMPLATE` - Default VM template (customizable)

## Integration with Projects and Workspaces

These variable sets can be associated with:

1. **Organization-wide**: Apply to all workspaces in your TFE organization
2. **Project-specific**: Apply to all workspaces within specific projects
3. **Workspace-specific**: Apply to individual workspaces

The team-foundation module typically associates these variable sets with projects, making the variables available to all workspaces within those projects.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_config"></a> [aws\_config](#input\_aws\_config) | Configuration for AWS environments | <pre>object({<br/>    enabled     = bool<br/>    region      = string<br/>    account_id  = string<br/>    vpc_id      = string<br/>    subnet_ids  = list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_azure_config"></a> [azure\_config](#input\_azure\_config) | Configuration for Azure environments | <pre>object({<br/>    enabled           = bool<br/>    subscription_id   = string<br/>    resource_group    = string<br/>    location          = string<br/>    virtual_network   = string<br/>    subnet_id         = string<br/>  })</pre> | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the TFE organization | `string` | n/a | yes |
| <a name="input_vsphere_config"></a> [vsphere\_config](#input\_vsphere\_config) | Configuration for vSphere environments | <pre>object({<br/>    enabled     = bool<br/>    datacenter  = string<br/>    cluster     = string<br/>    datastore   = string<br/>    network     = string<br/>    folder_path = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_varset_id"></a> [aws\_varset\_id](#output\_aws\_varset\_id) | ID of the AWS variable set |
| <a name="output_azure_varset_id"></a> [azure\_varset\_id](#output\_azure\_varset\_id) | ID of the Azure variable set |
| <a name="output_vsphere_varset_id"></a> [vsphere\_varset\_id](#output\_vsphere\_varset\_id) | ID of the vSphere variable set | 
