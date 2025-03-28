###################################################
# SSO Integration Module Outputs
###################################################

output "sso_enabled" {
  description = "Indicates if SSO is enabled for the organization"
  value       = true
}

output "team_management_enabled" {
  description = "Indicates if team management via SAML assertions is enabled"
  value       = var.enable_team_management
}

output "team_membership_attribute" {
  description = "The SAML attribute used for team membership mapping"
  value       = var.enable_team_management ? var.team_membership_attribute : null
}

output "configured_teams" {
  description = "List of teams configured with SSO team IDs for Active Directory group mapping"
  value       = {
    for team_key, team in tfe_team.teams : team_key => {
      name         = team.name
      sso_team_id  = team.sso_team_id
      id           = team.id
    }
  }
} 