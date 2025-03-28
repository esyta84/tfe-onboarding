# Outputs for App-X team

output "team_projects" {
  description = "Projects created for App-X team"
  value       = module.app_x_onboarding.team_projects["app-x"]
}

output "team_workspaces" {
  description = "Workspaces created for App-X team"
  value       = module.app_x_onboarding.team_workspaces["app-x"]
}

output "sso_team_configuration" {
  description = "SSO team configuration for App-X team"
  value       = module.app_x_onboarding.sso_team_mappings
} 