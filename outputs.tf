###################################################
# Administrative Team and Projects Outputs
###################################################

output "admin_team_id" {
  description = "The ID of the admin team"
  value       = module.admin_team.team_id
}

output "admin_project_ids" {
  description = "Map of admin project names to their IDs"
  value       = { for name, project in tfe_project.admin_projects : name => project.id }
}

###################################################
# Team Onboarding Outputs
###################################################

output "team_project_ids" {
  description = "Map of team names to their project IDs for each environment"
  value       = { for team_name, team in module.team_onboarding : team_name => team.project_ids }
}

output "team_ids" {
  description = "Map of team names to their team IDs"
  value       = { for team_name, team in module.team_permissions : team_name => team.team_id }
}

###################################################
# Workspace Outputs
###################################################

output "workspace_counts" {
  description = "Number of workspaces created for each team"
  value       = { for team_name, team in module.workspace_creation : team_name => team.workspace_count }
}

output "workspace_ids" {
  description = "Map of team names to their workspace IDs"
  value       = { for team_name, team in module.workspace_creation : team_name => team.workspace_ids }
}

###################################################
# Variable Sets Outputs
###################################################

output "platform_variable_sets" {
  description = "IDs of platform-specific variable sets"
  value = {
    vsphere = module.platform_varsets.vsphere_varset_id
    aws     = module.platform_varsets.aws_varset_id
    azure   = module.platform_varsets.azure_varset_id
  }
} 