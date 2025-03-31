# Keycloak SSO Integration Module

This module configures Keycloak Single Sign-On (SSO) integration for Terraform Enterprise, enabling team membership assignment based on Keycloak roles and SAML assertions.

## Features

- Configures Keycloak SSO for a Terraform Enterprise organization
- Supports two Keycloak variants:
  - Standard Keycloak
  - Red Hat build of Keycloak (Red Hat SSO)
- Enables automatic team membership management via SAML assertions
- Maps Keycloak roles to Terraform Enterprise teams using SSO Team IDs

## Prerequisites

- Terraform Enterprise organization must exist
- Keycloak instance must be properly configured with:
  - A SAML client for Terraform Enterprise
  - Appropriate roles that can be mapped to TFE teams
  - Client mappers to include role information in SAML assertions

## Usage

### Standard Keycloak Integration Example

```hcl
module "sso_integration" {
  source        = "./modules/sso-integration"
  organization  = "my-tfe-org"
  
  enable_team_management = true
  team_membership_attribute = "MemberOf"
  
  sso_configuration = {
    provider_type        = "keycloak"
    keycloak_metadata_url = "https://keycloak.example.com/auth/realms/master/protocol/saml/descriptor"
    keycloak_client_id   = "terraform-enterprise"
    keycloak_realm       = "master"
  }
  
  teams = {
    admins = {
      name        = "Administrators"
      sso_team_id = "keycloak-role-id-for-admins"
    },
    developers = {
      name        = "Developers"
      sso_team_id = "keycloak-role-id-for-developers"
    }
  }
}
```

### Red Hat build of Keycloak Example

```hcl
module "sso_integration" {
  source        = "./modules/sso-integration"
  organization  = "my-tfe-org"
  
  enable_team_management = true
  team_membership_attribute = "MemberOf"
  
  sso_configuration = {
    provider_type               = "keycloak_redhat"
    keycloak_redhat_metadata_url = "https://sso.example.com/auth/realms/master/protocol/saml/descriptor"
    keycloak_redhat_client_id   = "terraform-enterprise"
    keycloak_redhat_realm       = "master"
  }
  
  teams = {
    admins = {
      name        = "Administrators"
      sso_team_id = "keycloak-role-id-for-admins"
    },
    developers = {
      name        = "Developers"
      sso_team_id = "keycloak-role-id-for-developers"
    }
  }
}
```

## Keycloak Configuration Guide

### Setting Up Keycloak for Terraform Enterprise SSO

1. **Create a SAML Client in Keycloak**
   - Create a new client in your Keycloak realm
   - Set client ID to match your `keycloak_client_id` (e.g., "terraform-enterprise")
   - Set client protocol to "saml"
   - Configure the redirect URI to point to your TFE instance's SAML callback URL

2. **Configure Client Settings**
   - Set "Include AuthnStatement" to ON
   - Set "Sign Documents" to ON
   - Set "Sign Assertions" to ON
   - Set "Client Signature Required" to OFF
   - Set "Force POST Binding" to ON
   - Set "Force Name ID Format" to ON
   - Set "Name ID Format" to "email"

3. **Create Client Mappers**
   - Create a mapper for the MemberOf attribute:
     - Name: "role-list"
     - Mapper Type: "Role list"
     - Role attribute name: "MemberOf" (must match `team_membership_attribute`)
     - Friendly Name: "roles"
     - SAML Attribute NameFormat: "Basic"
     - Single Role Attribute: OFF

4. **Set Up Role Mappings**
   - Create roles in Keycloak that match your Terraform Enterprise teams
   - Assign users to these roles
   - Use the Keycloak role IDs as the `sso_team_id` values in your configuration

### Finding Keycloak Role IDs

To find the role IDs in Keycloak:

1. Log in to your Keycloak admin console
2. Navigate to your realm
3. Go to "Roles" section
4. Click on a role
5. The role ID is displayed in the URL (or in the role details)

## Manual Configuration Required

This module creates the necessary team associations with Keycloak role IDs, but the actual SSO connection must be established manually in the Terraform Enterprise admin console due to API limitations.

After applying this Terraform configuration:

1. Log in to your Terraform Enterprise instance as an admin
2. Navigate to your organization settings
3. Go to the "SSO" section
4. Configure the Keycloak SSO provider with the details from your `sso_configuration`
5. Enable team management and set the team membership attribute

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
| <a name="input_enable_team_management"></a> [enable\_team\_management](#input\_enable\_team\_management) | Whether to enable team management via SAML assertions | `bool` | `true` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | The name of the TFE organization | `string` | n/a | yes |
| <a name="input_sso_configuration"></a> [sso\_configuration](#input\_sso\_configuration) | Configuration for SSO integration | <pre>object({<br/>    provider_type = string # Only "keycloak" or "keycloak_redhat" are supported<br/>    <br/>    # For Keycloak (standard)<br/>    keycloak_metadata_url = optional(string)<br/>    keycloak_client_id    = optional(string)<br/>    keycloak_realm        = optional(string)<br/>    <br/>    # For Red Hat build of Keycloak<br/>    keycloak_redhat_metadata_url = optional(string)<br/>    keycloak_redhat_client_id    = optional(string)<br/>    keycloak_redhat_realm        = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_team_membership_attribute"></a> [team\_membership\_attribute](#input\_team\_membership\_attribute) | The SAML attribute name to use for team membership mapping | `string` | `"MemberOf"` | no |
| <a name="input_teams"></a> [teams](#input\_teams) | List of teams to create SSO Team IDs for (mapping from Keycloak roles to TFE Team names) | <pre>map(object({<br/>    name            = string<br/>    sso_team_id     = string # This should be the Keycloak role ID<br/>  }))</pre> | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configured_teams"></a> [configured\_teams](#output\_configured\_teams) | List of teams configured with SSO Team IDs for Keycloak role mapping |
| <a name="output_manual_sso_setup_required"></a> [manual\_sso\_setup\_required](#output\_manual\_sso\_setup\_required) | Flag indicating that manual Keycloak SSO setup is required in the TFE admin console |
| <a name="output_sso_enabled"></a> [sso\_enabled](#output\_sso\_enabled) | Indicates if Keycloak SSO is enabled for the organization |
| <a name="output_sso_provider_type"></a> [sso\_provider\_type](#output\_sso\_provider\_type) | Type of Keycloak SSO provider configured (standard or Red Hat) |
| <a name="output_sso_setup_instructions"></a> [sso\_setup\_instructions](#output\_sso\_setup\_instructions) | Output setup instructions for SSO configuration |
| <a name="output_team_management_enabled"></a> [team\_management\_enabled](#output\_team\_management\_enabled) | Indicates if team management via Keycloak SAML assertions is enabled |
| <a name="output_team_membership_attribute"></a> [team\_membership\_attribute](#output\_team\_membership\_attribute) | The SAML attribute used for Keycloak role-based team membership mapping |

## Best Practices

1. Use descriptive team names that align with your organizational structure
2. Keep team permissions consistent with your organization's security policies
3. Regularly audit role membership in Keycloak to ensure proper access control
4. Test SSO integration in a staging environment before deploying to production
5. Store sensitive SSO configuration outside of version control (like any other credentials) 
