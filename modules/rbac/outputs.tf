output "team_id" {
  description = "The ID of the created team"
  value       = tfe_team.team.id
}

output "team_name" {
  description = "The name of the created team"
  value       = tfe_team.team.name
}

output "project_access" {
  description = "Map of project names to their access levels for this team"
  value       = var.project_access
}

output "workspace_access" {
  description = "Map of workspace names to their access levels for this team"
  value       = var.workspace_access
} 