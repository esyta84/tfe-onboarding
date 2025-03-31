###################################################
# SSO Integration for Terraform Enterprise
###################################################

# Note: This is a simplified version of the SSO integration module
# that only sets up team SSO IDs for team mappings
# The organization settings for SSO and team membership management
# must be configured manually through the TFE admin console

###################################################
# SSO Configuration for Keycloak Integration
###################################################

# Conditional configuration that works with both Terraform Cloud and Terraform Enterprise
locals {
  # Use to determine if we should attempt to use cloud-specific resources
  is_cloud_compatible = true
  
  # Create instructions for Keycloak SSO setup
  sso_instruction_message = <<-EOT
  IMPORTANT: Keycloak SSO configuration must be done manually in the Terraform Enterprise UI:
  
  1. Go to your organization settings
  2. Navigate to the "SSO" section
  3. Configure your Keycloak SSO provider with these settings:
  
  Provider: ${var.sso_configuration.provider_type}
  ${var.sso_configuration.provider_type == "keycloak" ? "Metadata URL: ${var.sso_configuration.keycloak_metadata_url}" : ""}
  ${var.sso_configuration.provider_type == "keycloak" ? "Client ID: ${var.sso_configuration.keycloak_client_id}" : ""}
  ${var.sso_configuration.provider_type == "keycloak" ? "Realm: ${var.sso_configuration.keycloak_realm}" : ""}
  ${var.sso_configuration.provider_type == "keycloak_redhat" ? "Metadata URL: ${var.sso_configuration.keycloak_redhat_metadata_url}" : ""}
  ${var.sso_configuration.provider_type == "keycloak_redhat" ? "Client ID: ${var.sso_configuration.keycloak_redhat_client_id}" : ""}
  ${var.sso_configuration.provider_type == "keycloak_redhat" ? "Realm: ${var.sso_configuration.keycloak_redhat_realm}" : ""}
  
  4. Enable team management
  5. Set the team membership attribute to: ${var.team_membership_attribute}
  
  KEYCLOAK CONFIGURATION INSTRUCTIONS:
  
  1. Ensure your Keycloak realm has the appropriate client configuration for Terraform Enterprise
  2. Configure client mappers to include the ${var.team_membership_attribute} attribute in the SAML assertion
  3. Set up role mappings in Keycloak that correspond to the TFE team names
  4. Make sure the SAML response uses NameID format: urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress
  EOT
}

# Output setup instructions for SSO configuration
output "sso_setup_instructions" {
  value = local.sso_instruction_message
}

###################################################
# SSO Team IDs Configuration
###################################################

# Configure SSO Team IDs for mapping Keycloak roles to TFE teams
resource "tfe_team" "teams" {
  for_each = var.teams
  
  name         = each.value.name
  organization = var.organization
  visibility   = "organization"
  
  # Set the SSO Team ID to the Keycloak Role ID
  sso_team_id  = each.value.sso_team_id
} 