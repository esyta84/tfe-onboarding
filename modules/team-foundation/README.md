# Team Foundation Module

This module creates the foundational resources for a team in Terraform Enterprise, including projects for different environments, variable sets for team-specific settings, and workspaces for infrastructure management.

## Overview

The Team Foundation module:

- Creates projects for each environment (dev, preprod, prod) for a team
- Creates team-specific variable sets with cost code, team email, etc.
- Associates the variable sets with the appropriate projects
- Associates platform-specific variable sets (AWS, Azure, vSphere) with the projects
- Creates workspaces using the workspace-factory module

## Module Dependencies

This module:
1. First creates projects for each environment
2. Captures the project IDs in a local variable
3. Passes these project IDs to the workspace-factory module
4. The workspace-factory module then creates workspaces within these projects

This dependency flow ensures that projects exist before workspaces are created within them.

## Usage

```hcl
module "team_foundation" {
  source = "../modules/team-foundation"
  
  organization = "my-tfe-org"
  
  # Team configuration
  team_config = {
    name        = "engineering"
    description = "Engineering team workspaces"
    email       = "engineering@example.com"
    cost_code   = "CC-ENG-123"
  }
  
  # Environments to create for this team
  environments = ["dev", "preprod", "prod"]
  
  # Platforms this team will use
  platforms = ["aws", "azure", "vsphere"]
  
  # Variable set IDs for platforms
  platform_varset_ids = {
    aws     = module.platform_varsets.aws_varset_id
    azure   = module.platform_varsets.azure_varset_id
    vsphere = module.platform_varsets.vsphere_varset_id
  }
  
  # Environment-specific configurations
  environment_configs = var.environment_configs
  
  # AWS team configuration by environment
  aws_team_config = {
    dev = {
      region      = "ap-southeast-2"
      account_id  = "111111111111"
      vpc_id      = "vpc-dev111111111111"
      subnet_ids  = ["subnet-dev1111111", "subnet-dev2222222"]
    },
    preprod = {
      region      = "ap-southeast-2"
      account_id  = "222222222222"
      vpc_id      = "vpc-preprod22222222"
      subnet_ids  = ["subnet-preprod1111", "subnet-preprod2222"]
    },
    prod = {
      region      = "ap-southeast-2"
      account_id  = "333333333333"
      vpc_id      = "vpc-prod3333333333"
      subnet_ids  = ["subnet-prod1111111", "subnet-prod2222222"]
    }
  }
  
  # Azure team configuration by environment
  azure_team_config = {
    dev = {
      subscription_id = "00000000-0000-0000-0000-000000000001"
      resource_group  = "engineering-dev-rg"
      location        = "australiaeast" 
    },
    preprod = {
      subscription_id = "00000000-0000-0000-0000-000000000002"
      resource_group  = "engineering-preprod-rg"
      location        = "australiaeast"
    },
    prod = {
      subscription_id = "00000000-0000-0000-0000-000000000003"
      resource_group  = "engineering-prod-rg"
      location        = "australiaeast"
    }
  }
  
  # vSphere team configuration by environment
  vsphere_team_config = {
    dev = {
      datacenter  = "dc-01"
      cluster     = "cluster-dev"
      datastore   = "datastore-dev"
      network     = "network-dev"
      folder_path = "/vm/terraform-managed/engineering/dev"
    },
    preprod = {
      datacenter  = "dc-01"
      cluster     = "cluster-preprod" 
      datastore   = "datastore-preprod"
      network     = "network-preprod"
      folder_path = "/vm/terraform-managed/engineering/preprod"
    },
    prod = {
      datacenter  = "dc-02"
      cluster     = "cluster-prod"
      datastore   = "datastore-prod"
      network     = "network-prod"
      folder_path = "/vm/terraform-managed/engineering/prod"
    }
  }
}
```

## Requirements

## Requirements

No requirements.

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_team_config"></a> [aws\_team\_config](#input\_aws\_team\_config) | Team-specific AWS configuration per environment that overrides the global AWS config | `map(any)` | `null` | no |
| <a name="input_azure_team_config"></a> [azure\_team\_config](#input\_azure\_team\_config) | Team-specific Azure configuration per environment that overrides the global Azure config | `map(any)` | `null` | no |
| <a name="input_environment_configs"></a> [environment\_configs](#input\_environment\_configs) | Configuration for different environments | <pre>map(object({<br/>    auto_apply                = bool<br/>    terraform_version         = string<br/>    execution_mode            = string<br/>    terraform_working_dir     = string<br/>    speculative_enabled       = bool<br/>    allow_destroy_plan        = bool<br/>    file_triggers_enabled     = bool<br/>    trigger_prefixes          = list(string)<br/>    queue_all_runs            = bool<br/>    assessments_enabled       = bool<br/>    global_remote_state       = bool<br/>    run_operation_timeout     = number<br/>    workspace_name_prefix     = string<br/>  }))</pre> | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | List of environments to create projects for | `list(string)` | <pre>[<br/>  "dev",<br/>  "preprod",<br/>  "prod"<br/>]</pre> | no |
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the TFE organization | `string` | n/a | yes |
| <a name="input_platform_varset_ids"></a> [platform\_varset\_ids](#input\_platform\_varset\_ids) | Map of platform variable set IDs | `map(string)` | `{}` | no |
| <a name="input_platforms"></a> [platforms](#input\_platforms) | List of platforms this team will use (vsphere, aws, azure) | `list(string)` | n/a | yes |
| <a name="input_team_config"></a> [team\_config](#input\_team\_config) | Configuration for the team | <pre>object({<br/>    name         = string<br/>    description  = string<br/>    email        = string<br/>    cost_code    = string<br/>    platforms    = list(string)<br/>    environments = list(string)<br/>    admins       = list(string)<br/>    members      = list(string)<br/>    aws_config   = optional(map(any))<br/>    azure_config = optional(map(any))<br/>    vsphere_config = optional(map(any))<br/>  })</pre> | n/a | yes |
| <a name="input_vsphere_team_config"></a> [vsphere\_team\_config](#input\_vsphere\_team\_config) | Team-specific vSphere configuration per environment that overrides the global vSphere config | `map(any)` | `null` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_environments"></a> [environments](#output\_environments) | List of environments created for this team |
| <a name="output_project_ids"></a> [project\_ids](#output\_project\_ids) | Map of environment names to their project IDs |
| <a name="output_team_name"></a> [team\_name](#output\_team\_name) | Name of the team |
| <a name="output_team_varset_id"></a> [team\_varset\_id](#output\_team\_varset\_id) | ID of the team-specific variable set | 
