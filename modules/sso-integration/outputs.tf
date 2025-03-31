###################################################
# Keycloak SSO Integration Module Outputs
###################################################

output "sso_enabled" {
  description = "Indicates if Keycloak SSO is enabled for the organization"
  value       = true
}

output "team_management_enabled" {
  description = "Indicates if team management via Keycloak SAML assertions is enabled"
  value       = var.enable_team_management
}

output "team_membership_attribute" {
  description = "The SAML attribute used for Keycloak role-based team membership mapping"
  value       = var.enable_team_management ? var.team_membership_attribute : null
}

output "configured_teams" {
  description = "List of teams configured with SSO Team IDs for Keycloak role mapping"
  value       = {
    for team_key, team in tfe_team.teams : team_key => {
      name         = team.name
      sso_team_id  = team.sso_team_id
      id           = team.id
    }
  }
}

output "manual_sso_setup_required" {
  description = "Flag indicating that manual Keycloak SSO setup is required in the TFE admin console"
  value       = true
}

output "sso_provider_type" {
  description = "Type of Keycloak SSO provider configured (standard or Red Hat)"
  value       = var.sso_configuration.provider_type
} 