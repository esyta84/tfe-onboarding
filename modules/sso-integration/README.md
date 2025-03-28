# SSO Integration Module

This module configures Single Sign-On (SSO) integration for Terraform Enterprise, enabling team membership assignment based on identity provider groups and SAML assertions.

## Features

- Configures SSO for a Terraform Enterprise organization
- Supports multiple identity providers:
  - Okta
  - Azure Active Directory
  - Keycloak (standard)
  - Red Hat build of Keycloak
  - Generic SAML providers
- Enables automatic team membership management via SAML assertions
- Maps identity provider groups/roles to Terraform Enterprise teams using SSO Team IDs

## Prerequisites

- Terraform Enterprise organization must exist
- Identity provider (IdP) must be configured to send appropriate SAML assertions
- Groups or roles should be properly configured and accessible via SAML

## Usage

### Basic Usage with Azure AD

```hcl
module "sso_integration" {
  source        = "./modules/sso-integration"
  organization  = "my-tfe-org"
  
  sso_configuration = {
    provider_type          = "azure_ad"
    azure_ad_metadata_url  = "https://login.microsoftonline.com/tenant-id/federationmetadata/2007-06/federationmetadata.xml"
  }
  
  teams = {
    admins = {
      name        = "Administrators"
      sso_team_id = "ad-group-id-for-admins"
    },
    developers = {
      name        = "Developers"
      sso_team_id = "ad-group-id-for-developers"
    },
    operators = {
      name        = "Operators"
      sso_team_id = "ad-group-id-for-operators"
    }
  }
}
```

### Keycloak Integration Example

```hcl
module "sso_integration" {
  source        = "./modules/sso-integration"
  organization  = "my-tfe-org"
  
  sso_configuration = {
    provider_type        = "keycloak"
    keycloak_metadata_url = "https://keycloak.example.com/auth/realms/master/protocol/saml/descriptor"
    keycloak_client_id   = "terraform-enterprise"
    keycloak_realm       = "master"
  }
  
  # Use Keycloak roles instead of groups if preferred
  team_membership_attribute = "Roles"
  
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
  
  sso_configuration = {
    provider_type               = "keycloak_redhat"
    keycloak_redhat_metadata_url = "https://sso.example.com/auth/realms/master/protocol/saml/descriptor"
    keycloak_redhat_client_id   = "terraform-enterprise"
    keycloak_redhat_realm       = "master"
  }
  
  # Use Keycloak roles instead of groups if preferred
  team_membership_attribute = "Roles"
  
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

### Okta Integration Example

```hcl
module "sso_integration" {
  source        = "./modules/sso-integration"
  organization  = "my-tfe-org"
  
  sso_configuration = {
    provider_type     = "okta"
    okta_metadata_url = "https://your-okta-domain.okta.com/app/your-app-id/sso/saml/metadata"
  }
  
  teams = {
    admins = {
      name        = "Administrators"
      sso_team_id = "okta-group-id-for-admins"
    },
    developers = {
      name        = "Developers"
      sso_team_id = "okta-group-id-for-developers"
    }
  }
}
```

### Generic SAML Provider

```hcl
module "sso_integration" {
  source        = "./modules/sso-integration"
  organization  = "my-tfe-org"
  
  sso_configuration = {
    provider_type    = "generic_saml"
    saml_idp_metadata = file("path/to/idp-metadata.xml")
    saml_sso_url     = "https://your-idp.example.com/sso/saml"
    saml_certificate = file("path/to/idp-certificate.pem")
  }
  
  team_membership_attribute = "Groups"  # Customize based on your SAML provider
  
  teams = {
    # Your team mappings here
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| organization | The name of the Terraform Enterprise organization | string | - | yes |
| enable_team_management | Whether to enable team management via SAML assertions | bool | true | no |
| team_membership_attribute | The name of the SAML attribute that contains team membership information | string | "MemberOf" | no |
| sso_configuration | Configuration for the SSO provider | object | - | yes |
| teams | Map of teams to create with SSO Team IDs for identity provider group/role mapping | map(object) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| sso_enabled | Indicates if SSO is enabled for the organization |
| team_management_enabled | Indicates if team management via SAML assertions is enabled |
| team_membership_attribute | The SAML attribute used for team membership mapping |
| configured_teams | List of teams configured with SSO team IDs for identity provider mapping |

## Notes

- The team membership attribute name (`MemberOf` by default) may vary depending on your identity provider
  - For Keycloak, use "Roles" if you're mapping Keycloak roles instead of groups
- SSO Team IDs should match the group/role identifiers in your identity provider:
  - For Azure AD, the SSO Team IDs should be the Object IDs of the AD groups
  - For Keycloak, the SSO Team IDs should be the Role IDs or Group IDs from Keycloak
  - For Red Hat build of Keycloak, use the same approach as standard Keycloak
  - For Okta, the SSO Team IDs should be the Group IDs from Okta

## Keycloak-specific Configuration

### Standard Keycloak

When using standard Keycloak as your identity provider:

1. Set up a SAML client in Keycloak for Terraform Enterprise
2. Configure the client to include group/role memberships in the SAML assertions
3. Use the Role IDs or Group IDs as SSO Team IDs in your configuration
4. Set `team_membership_attribute` to "Roles" if using Keycloak roles instead of groups

### Red Hat build of Keycloak

Red Hat's build of Keycloak (Red Hat SSO) works similarly to standard Keycloak but has some vendor-specific configurations:

1. Set up a SAML client in Red Hat SSO for Terraform Enterprise
2. Configure client mappers to include group/role memberships in the SAML assertions
3. Use the Role IDs or Group IDs as SSO Team IDs
4. Set the provider_type to "keycloak_redhat" to enable specific handling for Red Hat SSO

## Best Practices

1. Use descriptive team names that align with your organizational structure
2. Keep team permissions consistent with your organization's security policies
3. Regularly audit group/role membership to ensure proper access control
4. Test SSO integration in a staging environment before deploying to production 