###################################################
# Team Creation
###################################################

# Create the team
resource "tfe_team" "team" {
  name         = var.team.name
  organization = var.organization
  visibility   = "organization"
  organization_access {
    manage_workspaces = var.team.organization_access.manage_workspaces
    manage_policies   = var.team.organization_access.manage_policies
    manage_modules    = var.team.organization_access.manage_modules
    manage_providers  = var.team.organization_access.manage_providers
    manage_run_tasks  = var.team.organization_access.manage_run_tasks
    manage_membership = var.team.organization_access.manage_membership
  }
}

###################################################
# Team Membership Management
###################################################

# Add admin members to the team
resource "tfe_team_members" "admins" {
  count = length(var.team.admins) > 0 ? 1 : 0
  
  team_id   = tfe_team.team.id
  usernames = var.team.admins
}

# Add regular members to the team
resource "tfe_team_members" "members" {
  count = length(var.team.members) > 0 ? 1 : 0
  
  team_id   = tfe_team.team.id
  usernames = var.team.members
}

###################################################
# Project Access Management
###################################################

# Loop through the project_access map and assign the appropriate permissions
resource "tfe_team_project_access" "project_access" {
  for_each = var.project_access
  
  team_id    = tfe_team.team.id
  project_id = data.tfe_project.projects[each.key].id
  access     = each.value
}

# Get project data for each project in the project_access map
data "tfe_project" "projects" {
  for_each = var.project_access
  
  name         = each.key
  organization = var.organization
}

###################################################
# Workspace Access Management
###################################################

# Loop through the workspace_access map and assign the appropriate permissions
resource "tfe_team_access" "workspace_access" {
  for_each = var.workspace_access
  
  team_id      = tfe_team.team.id
  workspace_id = data.tfe_workspace.workspaces[each.key].id
  
  # Map TFE workspace permissions to the correct format
  permissions {
    runs = each.value == "read" ? "read" : (
           each.value == "plan" ? "plan" : (
           each.value == "write" ? "apply" : "admin"
           ))
    variables = each.value == "read" ? "read" : (
               each.value == "plan" ? "read" : (
               each.value == "write" ? "write" : "write"
               ))
    state_versions = each.value == "read" ? "read" : (
                    each.value == "plan" ? "read" : (
                    each.value == "write" ? "read-outputs" : "write"
                    ))
    sentinel_mocks = each.value == "read" ? "none" : (
                    each.value == "plan" ? "none" : (
                    each.value == "write" ? "read" : "write"
                    ))
    workspace_locking = each.value == "read" ? false : (
                       each.value == "plan" ? false : (
                       each.value == "write" ? true : true
                       ))
    run_tasks = each.value == "read" ? "none" : (
                each.value == "plan" ? "none" : (
                each.value == "write" ? "read" : "write"
                ))
  }
}

# Get workspace data for each workspace in the workspace_access map
data "tfe_workspace" "workspaces" {
  for_each = var.workspace_access
  
  name         = each.key
  organization = var.organization
} 