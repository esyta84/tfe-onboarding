###################################################
# Local Variables
###################################################

locals {
  # Flatten the combination of environments and platforms
  env_platform_combos = flatten([
    for env in var.environments : [
      for platform in var.platforms : {
        env      = env
        platform = platform
      }
    ]
  ])
  
  # Create a map for easier lookup
  env_platform_map = {
    for combo in local.env_platform_combos : 
    "${combo.env}-${combo.platform}" => combo
  }
}

###################################################
# Workspace Creation
###################################################

# Create a workspace for each environment and platform combination
resource "tfe_workspace" "workspaces" {
  for_each = local.env_platform_map
  
  name         = "${var.environment_configs[each.value.env].workspace_name_prefix}${var.team_name}-${each.value.platform}"
  organization = var.organization
  project_id   = var.team_projects[each.value.env]
  description  = "${var.team_name} team ${each.value.platform} workspace for ${each.value.env} environment"
  
  # Apply environment-specific configuration
  auto_apply          = var.environment_configs[each.value.env].auto_apply
  terraform_version   = var.environment_configs[each.value.env].terraform_version
  execution_mode      = var.environment_configs[each.value.env].execution_mode
  working_directory   = var.environment_configs[each.value.env].terraform_working_dir
  speculative_enabled = var.environment_configs[each.value.env].speculative_enabled
  allow_destroy_plan  = var.environment_configs[each.value.env].allow_destroy_plan
  file_triggers_enabled = var.environment_configs[each.value.env].file_triggers_enabled
  trigger_prefixes    = var.environment_configs[each.value.env].trigger_prefixes
  queue_all_runs      = var.environment_configs[each.value.env].queue_all_runs
  assessments_enabled = var.environment_configs[each.value.env].assessments_enabled
  global_remote_state = var.environment_configs[each.value.env].global_remote_state
  
  tag_names = [
    var.team_name,
    each.value.env,
    each.value.platform
  ]
}

###################################################
# Workspace Variables
###################################################

# Add team-specific variables to each workspace
resource "tfe_workspace_variable" "team_variables" {
  for_each = {
    for combo in flatten([
      for workspace_key, workspace in tfe_workspace.workspaces : [
        for var_key, var_value in var.team_variables : {
          workspace_key = workspace_key
          workspace_id  = workspace.id
          var_key       = var_key
          var_value     = var_value
        }
      ]
    ]) : "${combo.workspace_key}-${combo.var_key}" => combo
  }
  
  workspace_id = each.value.workspace_id
  key          = each.value.var_key
  value        = each.value.var_value
  category     = "terraform"
  description  = "Team variable: ${each.value.var_key}"
  sensitive    = false
}

# Add environment-specific variables
resource "tfe_workspace_variable" "environment_name" {
  for_each = local.env_platform_map
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "environment"
  value        = each.value.env
  category     = "terraform"
  description  = "Environment name"
  sensitive    = false
}

# Add platform-specific variables
resource "tfe_workspace_variable" "platform_name" {
  for_each = local.env_platform_map
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "platform"
  value        = each.value.platform
  category     = "terraform"
  description  = "Platform name"
  sensitive    = false
}

# Add a variable for operation timeout, since we can't set it directly on the workspace
resource "tfe_workspace_variable" "operation_timeout" {
  for_each = local.env_platform_map
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "operation_timeout_minutes"
  value        = tostring(var.environment_configs[each.value.env].run_operation_timeout)
  category     = "terraform"
  description  = "Operation timeout in minutes"
  sensitive    = false
} 