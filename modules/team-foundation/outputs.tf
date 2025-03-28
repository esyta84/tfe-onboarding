output "project_ids" {
  description = "Map of environment names to their project IDs"
  value       = { for env, project in tfe_project.team_projects : env => project.id }
}

output "team_varset_id" {
  description = "ID of the team-specific variable set"
  value       = tfe_variable_set.team_variables.id
}

output "environments" {
  description = "List of environments created for this team"
  value       = var.environments
}

output "team_name" {
  description = "Name of the team"
  value       = var.team_config.name
} 