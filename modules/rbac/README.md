# RBAC Module

This module manages Role-Based Access Control (RBAC) in Terraform Enterprise, including team creation, permissions assignment, and project access.

## Overview

The RBAC module:

- Creates teams with specified members and permissions
- Assigns team membership for users
- Configures project-level access controls
- Supports both admin and regular teams
- Can be used to manage organization-wide permissions

## Usage

### Admin Team Example

```hcl
module "admin_team" {
  source = "../modules/rbac"
  
  organization = "my-tfe-org"
  
  # Create an admin team
  team_name        = "platform-admins"
  team_description = "Team responsible for managing TFE platform"
  team_visibility  = "organization"
  
  # Set admins and members
  admins  = ["admin1@example.com", "admin2@example.com"] 
  members = ["member1@example.com", "member2@example.com"]
  
  # Optional: Grant access to specific projects
  project_access = {
    "platform-management" = "admin"    # Admin access to platform management project
    "team-onboarding"     = "maintain" # Maintain access to team onboarding project
  }
}
```

### Regular Team with Project Access Example

```hcl
module "dev_team" {
  source = "../modules/rbac"
  
  organization = "my-tfe-org"
  
  team_name        = "developers"
  team_description = "Development team with limited access"
  team_visibility  = "organization"
  
  admins  = ["lead-dev@example.com"]
  members = ["dev1@example.com", "dev2@example.com", "dev3@example.com"]
  
  # Grant appropriate access levels to different projects
  project_access = {
    "app-dev"         = "write"    # Write access to development project
    "shared-modules"  = "read"     # Read access to shared modules
    "production"      = "read"     # Read-only access to production
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
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the TFE organization | `string` | n/a | yes |
| <a name="input_project_access"></a> [project\_access](#input\_project\_access) | Map of project names to access levels (read, write, maintain, admin) | `map(string)` | `{}` | no |
| <a name="input_team"></a> [team](#input\_team) | Team configuration for creation and permissions | <pre>object({<br/>    name        = string<br/>    description = string<br/>    admins      = list(string)<br/>    members     = list(string)<br/>    organization_access = object({<br/>      manage_workspaces = bool<br/>      manage_policies   = bool<br/>      manage_vcs        = bool<br/>      manage_modules    = bool<br/>      manage_providers  = bool<br/>      manage_run_tasks  = bool<br/>      manage_membership = bool<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_workspace_access"></a> [workspace\_access](#input\_workspace\_access) | Map of workspace names to access levels (read, plan, write, admin) | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_access"></a> [project\_access](#output\_project\_access) | Map of project names to their access levels for this team |
| <a name="output_team_id"></a> [team\_id](#output\_team\_id) | The ID of the created team |
| <a name="output_team_name"></a> [team\_name](#output\_team\_name) | The name of the created team |
| <a name="output_workspace_access"></a> [workspace\_access](#output\_workspace\_access) | Map of workspace names to their access levels for this team | 
