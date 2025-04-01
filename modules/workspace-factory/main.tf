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

  # Create flattened team variables for all workspaces
  workspace_vars = flatten([
    for key, combo in local.env_platform_map : [
      for var_key, var_value in var.team_variables : {
        workspace_key = key
        var_key       = var_key
        var_value     = var_value
      }
    ]
  ])

  # Use team-specific per-environment AWS configs if available
  effective_aws_configs = var.aws_team_config != null ? var.aws_team_config : {
    for env in var.environments : env => {
      region     = "ap-southeast-2" # Default to AP Southeast 2 if no team or global config
      account_id = null
      vpc_id     = null
      subnet_ids = []
    }
  }
  
  # Use team-specific per-environment Azure configs if available
  effective_azure_configs = var.azure_team_config != null ? var.azure_team_config : {
    for env in var.environments : env => {
      location       = "australiaeast" # Default to Australia East if no team or global config
      subscription_id = null
      resource_group = null
      vnet_name      = null
      subnet_names   = []
    }
  }
  
  # Use team-specific per-environment vSphere configs if available
  effective_vsphere_configs = var.vsphere_team_config != null ? var.vsphere_team_config : {
    for env in var.environments : env => {
      vsphere_server     = null
      datacenter         = null
      compute_cluster    = null
      datastore          = null
      resource_pool      = null
      folder             = null
      network            = null
    }
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
resource "tfe_variable" "team_variables" {
  for_each = {
    for item in local.workspace_vars : "${item.workspace_key}-${item.var_key}" => item
  }
  
  workspace_id = tfe_workspace.workspaces[each.value.workspace_key].id
  key          = each.value.var_key
  value        = each.value.var_value
  category     = "terraform"
  description  = "Team variable for ${each.value.var_key}"
  sensitive    = false
}

# Add environment-specific variables
resource "tfe_variable" "environment_name" {
  for_each = local.env_platform_map
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "environment"
  value        = each.value.env
  category     = "terraform"
  description  = "Environment for this workspace"
  sensitive    = false
}

# Add platform-specific variables
resource "tfe_variable" "platform_name" {
  for_each = local.env_platform_map
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "platform"
  value        = each.value.platform
  category     = "terraform"
  description  = "Platform for this workspace"
  sensitive    = false
}

###################################################
# Platform-Specific Variables
###################################################

# Set AWS-specific variables using the effective AWS config per environment
resource "tfe_variable" "aws_region" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "aws") && combo.platform == "aws" && lookup(local.effective_aws_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "AWS_REGION"
  value        = try(
    local.effective_aws_configs[each.value.env].region,
    "ap-southeast-2"
  )
  category     = "env"
  description  = "AWS region for resources in ${each.value.env} environment"
}

resource "tfe_variable" "aws_account_id" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "aws") && combo.platform == "aws" && lookup(local.effective_aws_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "TF_VAR_aws_account_id"
  value        = try(
    local.effective_aws_configs[each.value.env].account_id,
    ""
  )
  category     = "env"
  description  = "AWS account ID for ${each.value.env} environment"
}

# Set Azure-specific variables using the effective Azure config per environment
resource "tfe_variable" "azure_location" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "azure") && combo.platform == "azure" && lookup(local.effective_azure_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "ARM_LOCATION"
  value        = try(
    local.effective_azure_configs[each.value.env].location,
    "australiaeast"
  )
  category     = "env"
  description  = "Azure location for resources in ${each.value.env} environment"
}

resource "tfe_variable" "azure_subscription_id" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "azure") && combo.platform == "azure" && lookup(local.effective_azure_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "ARM_SUBSCRIPTION_ID"
  value        = try(
    local.effective_azure_configs[each.value.env].subscription_id,
    ""
  )
  category     = "env"
  description  = "Azure subscription ID for ${each.value.env} environment"
}

resource "tfe_variable" "azure_resource_group" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "azure") && combo.platform == "azure" && lookup(local.effective_azure_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "TF_VAR_azure_resource_group"
  value        = try(
    local.effective_azure_configs[each.value.env].resource_group,
    ""
  )
  category     = "env"
  description  = "Azure resource group for ${each.value.env} environment"
}

# Set vSphere-specific variables using the effective vSphere config per environment
resource "tfe_variable" "vsphere_server" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "vsphere") && combo.platform == "vsphere" && lookup(local.effective_vsphere_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "VSPHERE_SERVER"
  value        = try(
    local.effective_vsphere_configs[each.value.env].vsphere_server,
    ""
  )
  category     = "env"
  description  = "vSphere server for ${each.value.env} environment"
}

resource "tfe_variable" "vsphere_datacenter" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "vsphere") && combo.platform == "vsphere" && lookup(local.effective_vsphere_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "TF_VAR_vsphere_datacenter"
  value        = try(
    local.effective_vsphere_configs[each.value.env].datacenter,
    ""
  )
  category     = "env"
  description  = "vSphere datacenter for ${each.value.env} environment"
}

resource "tfe_variable" "vsphere_compute_cluster" {
  for_each = {
    for key, combo in local.env_platform_map :
    key => combo
    if contains(var.platforms, "vsphere") && combo.platform == "vsphere" && lookup(local.effective_vsphere_configs, combo.env, null) != null
  }
  
  workspace_id = tfe_workspace.workspaces[each.key].id
  key          = "TF_VAR_vsphere_compute_cluster"
  value        = try(
    local.effective_vsphere_configs[each.value.env].cluster,
    ""
  )
  category     = "env"
  description  = "vSphere compute cluster for ${each.value.env} environment"
} 