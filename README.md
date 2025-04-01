# Terraform Enterprise Onboarding Automation

This repository contains Terraform code for automating team onboarding to our Terraform Enterprise platform. It provides a scalable, modular approach to managing hundreds of workspaces across different teams and environments.

## Overview

This codebase enables the automated creation and management of:

- Team organizations in Terraform Enterprise
- Projects for different environments (dev, preprod, prod)
- Workspaces for different platforms (AWS, Azure, vSphere)
- Variable sets for platform-specific configurations
- Team-specific variables
- Administrative workflows for platform management
- Keycloak SSO integration for team membership management

## Module Dependency Flow

This automation follows a specific dependency flow:

1. **Team Foundation** - Creates the foundation for a team:
   - Creates projects for each environment
   - Creates team-specific variable sets
   - Associates platform variable sets with projects

2. **Workspace Factory** - Uses projects created by Team Foundation:
   - Takes project IDs as input from Team Foundation module
   - Creates workspaces within these existing projects
   - Configures platform-specific settings (AWS, Azure, vSphere)

This separation of concerns follows HashiCorp's best practices for TFE organization, where projects provide logical grouping and permissions control for workspaces.

## Repository Structure

```
.
├── README.md                       # This file
├── main.tf                         # Root module entry point
├── variables.tf                    # Global variables definition
├── outputs.tf                      # Global outputs
├── providers.tf                    # Provider configurations
├── terraform.tfvars.example        # Example variable values
├── environments/                   # Environment-specific variable files
│   ├── dev.tfvars                  # Development environment variables
│   ├── preprod.tfvars              # Pre-production environment variables
│   └── prod.tfvars                 # Production environment variables
├── modules/                        # Reusable modules
│   ├── team-foundation/            # Creates team projects and base structure
│   ├── workspace-factory/          # Creates and configures workspaces
│   ├── variable-sets/              # Manages variable sets
│   ├── sso-integration/            # Keycloak SSO integration
│   └── rbac/                       # Manages team permissions
├── teams/                          # Team-specific configurations
│   └── app-x/                      # Example team configuration
└── ci/                             # CI/CD pipeline configurations
    └── azure-devops/               # Azure DevOps pipelines
```

## Usage

This module follows standard Terraform usage patterns. The resources can be created and managed using standard Terraform workflow commands:

```bash
terraform init
terraform plan -var-file="terraform.tfvars" -var="tfe_token=YOUR_TOKEN"
terraform apply -var-file="terraform.tfvars" -var="tfe_token=YOUR_TOKEN"
```

### Important Note on Variable Set Associations

Due to the way Terraform evaluates `for_each` expressions, applying the variable set associations with projects requires a two-step process:

1. First, apply only the project resources:
```bash
terraform apply -var-file="terraform.tfvars" -var="tfe_token=YOUR_TOKEN" -target=module.team_onboarding.tfe_project.team_projects
```

2. Then, apply the entire configuration to create the variable set associations:
```bash
terraform apply -var-file="terraform.tfvars" -var="tfe_token=YOUR_TOKEN"
```

This two-step process is necessary because the variable set associations depend on resource attributes that are only known after the initial apply.

### Prerequisites

- Terraform >= 1.0.0
- Terraform Enterprise account with admin privileges
- API tokens with appropriate permissions

### Getting Started

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your specific values
3. Initialize Terraform: `terraform init`
4. Plan the changes: `terraform plan -var-file="terraform.tfvars"`
5. Apply the changes: `terraform apply -var-file="terraform.tfvars"`

### Adding a New Team

There are two ways to onboard a new team:

#### Manual Method
1. Create a new directory under `teams/` with the team name
2. Create the necessary configuration files (see example in `teams/app-x/`)
3. Run Terraform to apply the changes

#### Example: App-X Team Structure

We've included a complete example of team configuration for `app-x` that demonstrates the recommended folder structure:

```
teams/app-x/
├── README.md                     # Team-specific documentation
├── main.tf                       # Main configuration that uses the root module
├── variables.tf                  # Variable declarations for team config
├── outputs.tf                    # Team-specific outputs
├── team.tfvars                   # Team-specific variable values
├── workspaces/                   # Environment-specific workspaces
│   ├── dev/                      # Development environment
│   │   ├── main.tf               # Dev-specific resources
│   │   └── variables.tf          # Dev-specific variables
│   ├── preprod/                  # Similar structure for pre-production
│   └── prod/                     # Similar structure for production
└── platform-config/              # Platform-specific configurations
    ├── aws.tf                    # AWS-specific resources
    └── variables.tf              # Platform configuration variables
```

To use this example, copy the structure for your new team:

```bash
# Copy the example team structure
cp -r teams/app-x teams/your-new-team

# Update the team-specific configurations
# Edit teams/your-new-team/team.tfvars with your team details

# Apply the configuration
cd teams/your-new-team
terraform init
terraform plan -var-file="team.tfvars"
terraform apply -var-file="team.tfvars"
```

#### Automated Method Using Azure DevOps Pipeline
1. Use the Azure DevOps team onboarding pipeline (`ci/azure-devops/azure-pipelines-team-onboarding.yml`)
2. Provide the required team parameters through the Azure DevOps pipeline interface
3. The pipeline will automatically generate and apply the configuration

## Multi-cloud Platform Support

This project supports multiple cloud platforms to accommodate your organization's infrastructure needs:

### AWS Configuration
Configure AWS environment settings in your `terraform.tfvars` file:

```hcl
aws_config = {
  enabled    = true
  region     = "ap-southeast-2"
  account_id = "123456789012"
  vpc_id     = "vpc-abcdef123456"
  subnet_ids = ["subnet-abc123", "subnet-def456"]
}
```

### Azure Configuration
Configure Azure environment settings in your `terraform.tfvars` file:

```hcl
azure_config = {
  enabled         = true
  subscription_id = "00000000-0000-0000-0000-000000000000"
  resource_group  = "my-terraform-rg"
  location        = "australiaeast"
  virtual_network = "my-vnet"
  subnet_id       = "subnet-id-123"
}
```

### vSphere Configuration
Configure vSphere environment settings in your `terraform.tfvars` file:

```hcl
vsphere_config = {
  enabled        = true
  vcenter_server = "vcenter.example.com"
  datacenter     = "dc-01"
  cluster        = "cluster-01"
  datastore      = "datastore-01"
  network        = "network-01"
  folder_path    = "/vm/terraform-managed"
}
```

## SSO Integration for Team Membership

This project supports automatic team membership assignment based on Keycloak roles. The SSO integration module enables:

- Configuring SSO for your Terraform Enterprise organization
- Automatic team membership management via SAML assertions
- Mapping Keycloak roles to Terraform Enterprise teams using SSO Team IDs

### How It Works

1. When a user logs in via SSO, their SAML assertions include role memberships
2. Terraform Enterprise automatically assigns the user to teams based on the mapping between:
   - Keycloak role IDs (in the SAML attribute)
   - TFE Team SSO IDs (configured in this module)

### Supported Identity Providers

- Keycloak (standard)
- Red Hat build of Keycloak

### Configuration

Configure SSO integration in your `terraform.tfvars` file:

```hcl
# Enable team management via SAML assertions
enable_sso_team_management = true

# SAML attribute containing team membership information
sso_team_membership_attribute = "MemberOf"

# SSO Provider Configuration (choose one)
sso_configuration = {
  # Standard Keycloak Configuration
  provider_type = "keycloak"
  keycloak_metadata_url = "https://keycloak.example.com/auth/realms/master/protocol/saml/descriptor"
  keycloak_client_id = "terraform-enterprise"
  keycloak_realm = "master"
  
  # Uncomment for Red Hat build of Keycloak Configuration
  # provider_type = "keycloak_redhat"
  # keycloak_redhat_metadata_url = "https://sso.example.com/auth/realms/master/protocol/saml/descriptor"
  # keycloak_redhat_client_id = "terraform-enterprise"
  # keycloak_redhat_realm = "master"
}

# Map Keycloak Roles to TFE teams
sso_team_mappings = {
  admins = {
    name = "Administrators"
    sso_team_id = "a1b2c3d4-e5f6-0000-0000-000000000001"  # Keycloak role ID
  }
}
```

## Recommended Project and Workspace Hierarchy

When using Terraform Enterprise to manage itself (meta-terraform), we recommend the following project and workspace hierarchy:

### 1. Core Platform Project
```
terraform-platform/
├── tfe-core-infrastructure      # Core TFE installation and infrastructure
├── tfe-admin-settings           # Global TFE admin settings  
└── tfe-sso-integration          # Keycloak SSO integration
```

### 2. Team Onboarding Project
```
team-onboarding/
├── engineering-team-config      # Engineering team's workspaces and permissions
├── finance-team-config          # Finance team's workspaces and permissions
└── platform-team-config         # Platform team's workspaces and permissions
```

### 3. Platform Modules Project
```
platform-modules/
├── workspace-factory            # Module for workspace creation
├── team-foundation              # Module for team setup
└── policy-sets                  # Sentinel policies for governance
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5.0 |
| <a name="requirement_tfe"></a> [tfe](#requirement\_tfe) | ~> 0.64.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tfe"></a> [tfe](#provider\_tfe) | ~> 0.64.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin_team"></a> [admin\_team](#module\_admin\_team) | ./modules/rbac | n/a |
| <a name="module_platform_varsets"></a> [platform\_varsets](#module\_platform\_varsets) | ./modules/variable-sets | n/a |
| <a name="module_sso_integration"></a> [sso\_integration](#module\_sso\_integration) | ./modules/sso-integration | n/a |
| <a name="module_team_onboarding"></a> [team\_onboarding](#module\_team\_onboarding) | ./modules/team-foundation | n/a |
| <a name="module_team_permissions"></a> [team\_permissions](#module\_team\_permissions) | ./modules/rbac | n/a |
| <a name="module_workspace_creation"></a> [workspace\_creation](#module\_workspace\_creation) | ./modules/workspace-factory | n/a |

## Resources

| Name | Type |
|------|------|
| [tfe_organization.org](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/organization) | resource |
| [tfe_project.admin_projects](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/project) | resource |
| [tfe_team_project_access.admin_project_access](https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/team_project_access) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_projects"></a> [admin\_projects](#input\_admin\_projects) | List of administrative projects to create | <pre>list(object({<br/>    name        = string<br/>    description = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "For managing the TFE platform itself",<br/>    "name": "platform-management"<br/>  },<br/>  {<br/>    "description": "For automating workspace creation",<br/>    "name": "workspace-provisioning"<br/>  }<br/>]</pre> | no |
| <a name="input_admin_team"></a> [admin\_team](#input\_admin\_team) | Configuration for the platform admin team | <pre>object({<br/>    name        = string<br/>    description = string<br/>    admins      = list(string)<br/>    members     = list(string)<br/>  })</pre> | <pre>{<br/>  "admins": [],<br/>  "description": "Team responsible for managing TFE platform",<br/>  "members": [],<br/>  "name": "platform-admins"<br/>}</pre> | no |
| <a name="input_aws_config"></a> [aws\_config](#input\_aws\_config) | Configuration for AWS environments | <pre>object({<br/>    enabled     = bool<br/>    region      = string<br/>    account_id  = string<br/>    vpc_id      = string<br/>    subnet_ids  = list(string)<br/>  })</pre> | <pre>{<br/>  "account_id": "",<br/>  "enabled": false,<br/>  "region": "ap-southeast-2",<br/>  "subnet_ids": [],<br/>  "vpc_id": ""<br/>}</pre> | no |
| <a name="input_azure_config"></a> [azure\_config](#input\_azure\_config) | Configuration for Azure environments | <pre>object({<br/>    enabled           = bool<br/>    subscription_id   = string<br/>    resource_group    = string<br/>    location          = string<br/>    virtual_network   = string<br/>    subnet_id         = string<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "location": "eastus",<br/>  "resource_group": "",<br/>  "subnet_id": "",<br/>  "subscription_id": "",<br/>  "virtual_network": ""<br/>}</pre> | no |
| <a name="input_enable_sso_team_management"></a> [enable\_sso\_team\_management](#input\_enable\_sso\_team\_management) | Whether to enable team management via SAML assertions | `bool` | `false` | no |
| <a name="input_environment_configs"></a> [environment\_configs](#input\_environment\_configs) | Configuration for different environments | <pre>map(object({<br/>    auto_apply                = bool<br/>    terraform_version         = string<br/>    execution_mode            = string<br/>    terraform_working_dir     = string<br/>    speculative_enabled       = bool<br/>    allow_destroy_plan        = bool<br/>    file_triggers_enabled     = bool<br/>    trigger_prefixes          = list(string)<br/>    queue_all_runs            = bool<br/>    assessments_enabled       = bool<br/>    global_remote_state       = bool<br/>    run_operation_timeout     = number # In minutes<br/>    workspace_name_prefix     = string # Can be used to prefix workspace names<br/>  }))</pre> | <pre>{<br/>  "dev": {<br/>    "allow_destroy_plan": true,<br/>    "assessments_enabled": false,<br/>    "auto_apply": true,<br/>    "execution_mode": "remote",<br/>    "file_triggers_enabled": true,<br/>    "global_remote_state": false,<br/>    "queue_all_runs": false,<br/>    "run_operation_timeout": 30,<br/>    "speculative_enabled": true,<br/>    "terraform_version": "1.6.0",<br/>    "terraform_working_dir": "",<br/>    "trigger_prefixes": [],<br/>    "workspace_name_prefix": "dev-"<br/>  },<br/>  "preprod": {<br/>    "allow_destroy_plan": false,<br/>    "assessments_enabled": true,<br/>    "auto_apply": false,<br/>    "execution_mode": "remote",<br/>    "file_triggers_enabled": true,<br/>    "global_remote_state": true,<br/>    "queue_all_runs": true,<br/>    "run_operation_timeout": 60,<br/>    "speculative_enabled": true,<br/>    "terraform_version": "1.6.0",<br/>    "terraform_working_dir": "",<br/>    "trigger_prefixes": [],<br/>    "workspace_name_prefix": "preprod-"<br/>  },<br/>  "prod": {<br/>    "allow_destroy_plan": false,<br/>    "assessments_enabled": true,<br/>    "auto_apply": false,<br/>    "execution_mode": "remote",<br/>    "file_triggers_enabled": true,<br/>    "global_remote_state": true,<br/>    "queue_all_runs": true,<br/>    "run_operation_timeout": 120,<br/>    "speculative_enabled": true,<br/>    "terraform_version": "1.6.0",<br/>    "terraform_working_dir": "",<br/>    "trigger_prefixes": [],<br/>    "workspace_name_prefix": "prod-"<br/>  }<br/>}</pre> | no |
| <a name="input_sso_configuration"></a> [sso\_configuration](#input\_sso\_configuration) | Configuration for the Keycloak SSO provider integration | <pre>object({<br/>    provider_type = string<br/>    <br/>    # Keycloak configuration<br/>    keycloak_metadata_url = optional(string)<br/>    keycloak_client_id = optional(string)<br/>    keycloak_realm = optional(string)<br/>    <br/>    # Red Hat Keycloak configuration<br/>    keycloak_redhat_metadata_url = optional(string)<br/>    keycloak_redhat_client_id = optional(string)<br/>    keycloak_redhat_realm = optional(string)<br/>  })</pre> | <pre>{<br/>  "provider_type": "none"<br/>}</pre> | no |
| <a name="input_sso_team_mappings"></a> [sso\_team\_mappings](#input\_sso\_team\_mappings) | Map of teams to create with SSO Team IDs for Keycloak role mapping | <pre>map(object({<br/>    name        = string<br/>    sso_team_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_sso_team_membership_attribute"></a> [sso\_team\_membership\_attribute](#input\_sso\_team\_membership\_attribute) | The name of the SAML attribute containing team membership information | `string` | `"MemberOf"` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | Map of teams to be onboarded with their configurations | <pre>map(object({<br/>    name        = string<br/>    description = string<br/>    email       = string<br/>    cost_code   = string<br/>    platforms   = list(string) # List of platforms the team will use: "vsphere", "aws", "azure"<br/>    environments = list(string) # By default, this is ["dev", "preprod", "prod"], but can be customized<br/>    admins      = list(string) # List of team admin email addresses<br/>    members     = list(string) # List of team member email addresses<br/>  }))</pre> | `{}` | no |
| <a name="input_tfe_hostname"></a> [tfe\_hostname](#input\_tfe\_hostname) | The hostname of the Terraform Enterprise instance | `string` | `"app.terraform.io"` | no |
| <a name="input_tfe_org_email"></a> [tfe\_org\_email](#input\_tfe\_org\_email) | Email address for the Terraform Enterprise organization | `string` | `"admin@example.com"` | no |
| <a name="input_tfe_organization"></a> [tfe\_organization](#input\_tfe\_organization) | Name of the Terraform Enterprise organization | `string` | n/a | yes |
| <a name="input_tfe_token"></a> [tfe\_token](#input\_tfe\_token) | The API token for authenticating to Terraform Enterprise | `string` | n/a | yes |
| <a name="input_vsphere_config"></a> [vsphere\_config](#input\_vsphere\_config) | Configuration for vSphere environments | <pre>object({<br/>    enabled     = bool<br/>    datacenter  = string<br/>    cluster     = string<br/>    datastore   = string<br/>    network     = string<br/>    folder_path = string<br/>  })</pre> | <pre>{<br/>  "cluster": "",<br/>  "datacenter": "",<br/>  "datastore": "",<br/>  "enabled": false,<br/>  "folder_path": "",<br/>  "network": ""<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_project_ids"></a> [admin\_project\_ids](#output\_admin\_project\_ids) | Map of admin project names to their IDs |
| <a name="output_admin_team_id"></a> [admin\_team\_id](#output\_admin\_team\_id) | The ID of the admin team |
| <a name="output_platform_variable_sets"></a> [platform\_variable\_sets](#output\_platform\_variable\_sets) | IDs of platform-specific variable sets |
| <a name="output_team_ids"></a> [team\_ids](#output\_team\_ids) | Map of team names to their team IDs |
| <a name="output_team_project_ids"></a> [team\_project\_ids](#output\_team\_project\_ids) | Map of team names to their project IDs for each environment |
| <a name="output_workspace_counts"></a> [workspace\_counts](#output\_workspace\_counts) | Number of workspaces created for each team |
| <a name="output_workspace_ids"></a> [workspace\_ids](#output\_workspace\_ids) | Map of team names to their workspace IDs | 
