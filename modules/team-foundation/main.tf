###################################################
# Team Projects
###################################################

# Create a project for each environment (dev, preprod, prod)
resource "tfe_project" "team_projects" {
  for_each = toset(var.environments)
  
  name         = "${var.team_config.name}-${each.value}"
  organization = var.organization
  description  = "${var.team_config.name} ${each.value} environment"
}

# Create a map of environment to project ID for use in workspace creation
locals {
  project_ids = {
    for env in var.environments : env => tfe_project.team_projects[env].id
  }
}

###################################################
# Team Variable Sets
###################################################

# Create a team-specific variable set for common variables (cost code, etc.)
resource "tfe_variable_set" "team_variables" {
  name         = "${var.team_config.name}-team-variables"
  description  = "Team-specific variables for ${var.team_config.name}"
  organization = var.organization
  global       = false
}

# Associate the team variable set with each project
resource "tfe_project_variable_set" "team_varset_association" {
  for_each = toset(var.environments)
  
  variable_set_id = tfe_variable_set.team_variables.id
  project_id      = tfe_project.team_projects[each.value].id
}

# Add team-specific variables to the variable set
resource "tfe_variable" "cost_code" {
  key             = "cost_code"
  value           = var.team_config.cost_code
  category        = "terraform"
  description     = "Team cost code for resource tagging"
  variable_set_id = tfe_variable_set.team_variables.id
  sensitive       = false
}

resource "tfe_variable" "team_email" {
  key             = "team_email"
  value           = var.team_config.email
  category        = "terraform"
  description     = "Team contact email"
  variable_set_id = tfe_variable_set.team_variables.id
  sensitive       = false
}

resource "tfe_variable" "team_name" {
  key             = "team_name"
  value           = var.team_config.name
  category        = "terraform"
  description     = "Team name for resource tagging"
  variable_set_id = tfe_variable_set.team_variables.id
  sensitive       = false
}

###################################################
# Platform Variable Set Associations
###################################################

# We need to restructure the for_each logic to use only known values at plan time
locals {
  # Create a map of all environment/platform combinations that need variable sets
  vsphere_environments = contains(var.platforms, "vsphere") ? toset(var.environments) : toset([])
  aws_environments     = contains(var.platforms, "aws") ? toset(var.environments) : toset([])
  azure_environments   = contains(var.platforms, "azure") ? toset(var.environments) : toset([])
  
  # Make a map of platform to environments that can be used safely at plan time
  platform_environments = {
    "vsphere" = local.vsphere_environments
    "aws"     = local.aws_environments
    "azure"   = local.azure_environments
  }
  
  # Environment/platform combinations for variable set associations
  # This only creates associations for platforms that:
  # 1. Are requested by the team AND
  # 2. Have a non-empty variable set ID specified
  vsphere_varset_environments = length(local.vsphere_environments) > 0 && lookup(var.platform_varset_ids, "vsphere", "") != "" ? local.vsphere_environments : []
  aws_varset_environments = length(local.aws_environments) > 0 && lookup(var.platform_varset_ids, "aws", "") != "" ? local.aws_environments : []
  azure_varset_environments = length(local.azure_environments) > 0 && lookup(var.platform_varset_ids, "azure", "") != "" ? local.azure_environments : []
}

# Associate the vSphere variable set with relevant projects if vSphere is enabled and varset is provided
resource "tfe_project_variable_set" "vsphere_varset_association" {
  for_each = toset(local.vsphere_varset_environments)
  
  variable_set_id = lookup(var.platform_varset_ids, "vsphere", "")
  project_id      = tfe_project.team_projects[each.value].id
}

# Associate the AWS variable set with relevant projects if AWS is enabled and varset is provided
resource "tfe_project_variable_set" "aws_varset_association" {
  for_each = toset(local.aws_varset_environments)
  
  variable_set_id = lookup(var.platform_varset_ids, "aws", "")
  project_id      = tfe_project.team_projects[each.value].id
}

# Associate the Azure variable set with relevant projects if Azure is enabled and varset is provided
resource "tfe_project_variable_set" "azure_varset_association" {
  for_each = toset(local.azure_varset_environments)
  
  variable_set_id = lookup(var.platform_varset_ids, "azure", "")
  project_id      = tfe_project.team_projects[each.value].id
}

# Create workspaces for this team
module "workspaces" {
  source = "../workspace-factory"
  
  organization        = var.organization
  team_name           = var.team_config.name
  team_projects       = local.project_ids
  environments        = var.environments
  platforms           = var.platforms
  environment_configs = var.environment_configs
  
  # Pass team-specific variables to be set at workspace level
  team_variables = {
    cost_code = var.team_config.cost_code
    team_email = var.team_config.email
  }
  
  # Pass team-specific platform configurations
  aws_team_config     = var.aws_team_config
  azure_team_config   = var.azure_team_config
  vsphere_team_config = var.vsphere_team_config
  
  depends_on = [
    tfe_project.team_projects
  ]
} 