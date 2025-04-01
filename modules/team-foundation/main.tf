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

# NOTE: Due to the design of Terraform's evaluation of for_each expressions,
# the variable set associations need to be applied in a separate step.
# This is because they depend on resource attributes that are only known after apply.
# 
# To apply this configuration:
# 1. First apply the base resources: terraform apply -var tfe_token=your_token -target=tfe_project.team_projects
# 2. Then apply the full configuration: terraform apply -var tfe_token=your_token
#
# The conditional creation of these associations depends on:
# - The platforms enabled for this team
# - The variable set IDs being provided
# - The projects being successfully created

# vSphere variable set associations
resource "tfe_project_variable_set" "vsphere_varset" {
  for_each = {
    for env in var.environments : env => env
    if contains(var.platforms, "vsphere") && var.platform_varset_ids["vsphere"] != ""
  }
  
  variable_set_id = var.platform_varset_ids["vsphere"]
  project_id      = tfe_project.team_projects[each.key].id
}

# AWS variable set associations
resource "tfe_project_variable_set" "aws_varset" {
  for_each = {
    for env in var.environments : env => env
    if contains(var.platforms, "aws") && var.platform_varset_ids["aws"] != ""
  }
  
  variable_set_id = var.platform_varset_ids["aws"]
  project_id      = tfe_project.team_projects[each.key].id
}

# Azure variable set associations
resource "tfe_project_variable_set" "azure_varset" {
  for_each = {
    for env in var.environments : env => env
    if contains(var.platforms, "azure") && var.platform_varset_ids["azure"] != ""
  }
  
  variable_set_id = var.platform_varset_ids["azure"]
  project_id      = tfe_project.team_projects[each.key].id
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