output "workspace_ids" {
  description = "Map of workspace keys to their IDs"
  value       = { for key, workspace in tfe_workspace.workspaces : key => workspace.id }
}

output "workspace_names" {
  description = "Map of workspace keys to their names"
  value       = { for key, workspace in tfe_workspace.workspaces : key => workspace.name }
}

output "workspace_count" {
  description = "Number of workspaces created"
  value       = length(tfe_workspace.workspaces)
}

output "workspace_urls" {
  description = "URLs to access the workspaces in TFE UI"
  value       = { 
    for key, workspace in tfe_workspace.workspaces : 
    key => "https://${var.organization}.app.terraform.io/app/${var.organization}/workspaces/${workspace.name}" 
  }
} 