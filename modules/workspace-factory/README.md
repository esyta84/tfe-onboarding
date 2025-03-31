# Workspace Factory Module

This module creates and configures workspaces in Terraform Enterprise for different environments and cloud platforms.

## Overview

The Workspace Factory module:

- Creates workspaces for each combination of environment and platform
- Configures workspace settings based on environment-specific configurations
- Sets up workspace variables for different cloud platforms (AWS, Azure, vSphere)
- Organizes workspaces within team-specific projects
- **Uses IDs of existing projects** that must be created beforehand (e.g., by the team-foundation module)

## Project Dependency

> **Important**: This module does not create projects. It requires project IDs to be passed in through the `team_projects` parameter. These projects should be created beforehand, typically using the team-foundation module.

The dependency flow works as follows:
1. The team-foundation module creates projects and captures their IDs in its outputs
2. These project IDs are passed to the workspace-factory module
3. The workspace-factory module creates workspaces within these existing projects

## Usage

```hcl
module "workspace_factory" {
  source = "../modules/workspace-factory"
  
  organization = "my-tfe-org"
  team_name    = "engineering"
  
  # Map of environment names to project IDs
  # These IDs come from the team-foundation module's output
  team_projects = {
    "dev"     = "prj-AbCdEf123456"
    "preprod" = "prj-GhIjKl789012"
    "prod"    = "prj-MnOpQr345678"
  }
  
  # List of environments to create workspaces for
  environments = ["dev", "preprod", "prod"]
  
  # List of cloud platforms to create workspaces for
  platforms = ["aws", "azure", "vsphere"]
  
  # Environment-specific configurations
  environment_configs = {
    dev = {
      auto_apply           = true
      terraform_version    = "1.6.0"
      execution_mode       = "remote"
      allow_destroy_plan   = true
      workspace_name_prefix = "dev-"
      # ... other settings
    },
    preprod = {
      auto_apply           = false
      terraform_version    = "1.6.0"
      execution_mode       = "remote"
      allow_destroy_plan   = false
      workspace_name_prefix = "preprod-"
      # ... other settings
    },
    prod = {
      auto_apply           = false
      terraform_version    = "1.6.0"
      execution_mode       = "remote"
      allow_destroy_plan   = false
      workspace_name_prefix = "prod-"
      # ... other settings
    }
  }
  
  # Team-specific variables to set in workspaces
  team_variables = {
    cost_code = "CC-ENG-123"
    team_email = "engineering@example.com"
  }
  
  # AWS configuration for each environment
  aws_team_config = {
    dev = {
      region     = "ap-southeast-2"
      account_id = "111111111111"
      vpc_id     = "vpc-dev111111111111"
      subnet_ids = ["subnet-dev1111111", "subnet-dev2222222"]
    },
    preprod = {
      region     = "ap-southeast-2"
      account_id = "222222222222"
      vpc_id     = "vpc-preprod22222222"
      subnet_ids = ["subnet-preprod1111", "subnet-preprod2222"]
    },
    prod = {
      region     = "ap-southeast-2"
      account_id = "333333333333"
      vpc_id     = "vpc-prod3333333333"
      subnet_ids = ["subnet-prod1111111", "subnet-prod2222222"]
    }
  }
  
  # Azure configuration for each environment
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
  
  # vSphere configuration for each environment
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

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_team_config"></a> [aws\_team\_config](#input\_aws\_team\_config) | Team-specific AWS configuration per environment that overrides the global AWS config | `map(any)` | `null` | no |
| <a name="input_azure_team_config"></a> [azure\_team\_config](#input\_azure\_team\_config) | Team-specific Azure configuration per environment that overrides the global Azure config | `map(any)` | `null` | no |
| <a name="input_environment_configs"></a> [environment\_configs](#input\_environment\_configs) | Configuration for different environments | <pre>map(object({<br/>    auto_apply                = bool<br/>    terraform_version         = string<br/>    execution_mode            = string<br/>    terraform_working_dir     = string<br/>    speculative_enabled       = bool<br/>    allow_destroy_plan        = bool<br/>    file_triggers_enabled     = bool<br/>    trigger_prefixes          = list(string)<br/>    queue_all_runs            = bool<br/>    assessments_enabled       = bool<br/>    global_remote_state       = bool<br/>    run_operation_timeout     = number<br/>    workspace_name_prefix     = string<br/>  }))</pre> | n/a | yes |
| <a name="input_environments"></a> [environments](#input\_environments) | List of environments to create workspaces for | `list(string)` | <pre>[<br/>  "dev",<br/>  "preprod",<br/>  "prod"<br/>]</pre> | no |
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the TFE organization | `string` | n/a | yes |
| <a name="input_platform_workspace_count"></a> [platform\_workspace\_count](#input\_platform\_workspace\_count) | Number of workspaces to create per platform | <pre>map(object({<br/>    vsphere = number<br/>    aws     = number<br/>    azure   = number<br/>  }))</pre> | <pre>{<br/>  "dev": {<br/>    "aws": 1,<br/>    "azure": 1,<br/>    "vsphere": 1<br/>  },<br/>  "preprod": {<br/>    "aws": 1,<br/>    "azure": 1,<br/>    "vsphere": 1<br/>  },<br/>  "prod": {<br/>    "aws": 1,<br/>    "azure": 1,<br/>    "vsphere": 1<br/>  }<br/>}</pre> | no |
| <a name="input_platforms"></a> [platforms](#input\_platforms) | List of platforms this team will use (vsphere, aws, azure) | `list(string)` | n/a | yes |
| <a name="input_team_name"></a> [team\_name](#input\_team\_name) | Name of the team | `string` | n/a | yes |
| <a name="input_team_projects"></a> [team\_projects](#input\_team\_projects) | Map of environment names to their project IDs | `map(string)` | n/a | yes |
| <a name="input_team_variables"></a> [team\_variables](#input\_team\_variables) | Map of team-specific variables to be set on workspaces | `map(string)` | `{}` | no |
| <a name="input_vsphere_team_config"></a> [vsphere\_team\_config](#input\_vsphere\_team\_config) | Team-specific vSphere configuration per environment that overrides the global vSphere config | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_count"></a> [workspace\_count](#output\_workspace\_count) | Number of workspaces created |
| <a name="output_workspace_ids"></a> [workspace\_ids](#output\_workspace\_ids) | Map of workspace keys to their IDs |
| <a name="output_workspace_names"></a> [workspace\_names](#output\_workspace\_names) | Map of workspace keys to their names |
| <a name="output_workspace_urls"></a> [workspace\_urls](#output\_workspace\_urls) | URLs to access the workspaces in TFE UI | 
