###################################################
# SSO Configuration
###################################################

# Configure SSO for the organization
resource "tfe_organization_settings" "sso_settings" {
  organization = var.organization
  
  # Enable SAML SSO by configuring settings based on provider type
  dynamic "sso" {
    for_each = var.sso_configuration.provider_type == "okta" ? [1] : []
    content {
      enabled     = true
      debug       = false
      idp_metadata_url = var.sso_configuration.okta_metadata_url
    }
  }
  
  dynamic "sso" {
    for_each = var.sso_configuration.provider_type == "azure_ad" ? [1] : []
    content {
      enabled     = true
      debug       = false
      idp_metadata_url = var.sso_configuration.azure_ad_metadata_url
    }
  }
  
  # Standard Keycloak configuration
  dynamic "sso" {
    for_each = var.sso_configuration.provider_type == "keycloak" ? [1] : []
    content {
      enabled     = true
      debug       = false
      idp_metadata_url = var.sso_configuration.keycloak_metadata_url
      
      # Additional Keycloak attributes
      attributes = {
        "client_id" = var.sso_configuration.keycloak_client_id
        "realm"     = var.sso_configuration.keycloak_realm
      }
    }
  }
  
  # Red Hat build of Keycloak configuration
  dynamic "sso" {
    for_each = var.sso_configuration.provider_type == "keycloak_redhat" ? [1] : []
    content {
      enabled     = true
      debug       = false
      idp_metadata_url = var.sso_configuration.keycloak_redhat_metadata_url
      
      # Additional Red Hat Keycloak attributes
      attributes = {
        "client_id" = var.sso_configuration.keycloak_redhat_client_id
        "realm"     = var.sso_configuration.keycloak_redhat_realm
        "provider"  = "redhat-sso"
      }
    }
  }
  
  dynamic "sso" {
    for_each = var.sso_configuration.provider_type == "generic_saml" ? [1] : []
    content {
      enabled     = true
      debug       = false
      idp_metadata = var.sso_configuration.saml_idp_metadata
      sso_url     = var.sso_configuration.saml_sso_url
      certificate = var.sso_configuration.saml_certificate
    }
  }
}

###################################################
# Team Management Configuration
###################################################

# Configure team management via SAML
resource "tfe_organization_membership_management" "team_mapping" {
  count = var.enable_team_management ? 1 : 0
  
  organization = var.organization
  enabled      = true
  team_map_attribute = var.team_membership_attribute
}

###################################################
# SSO Team IDs Configuration
###################################################

# Configure SSO Team IDs for mapping groups/roles to TFE teams
resource "tfe_team" "teams" {
  for_each = var.teams
  
  name         = each.value.name
  organization = var.organization
  visibility   = "organization"
  
  # Set the SSO Team ID to the Group ID or Keycloak Role ID
  sso_team_id  = each.value.sso_team_id
} 