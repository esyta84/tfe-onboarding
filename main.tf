###################################################
# TFE Organization Configuration
###################################################

# Create or use existing organization in Terraform Enterprise
resource "tfe_organization" "org" {
  name  = var.tfe_organization
  email = var.tfe_org_email
}

###################################################
# Administrative Team and Projects
###################################################

# Create the admin team for platform management
module "admin_team" {
  source      = "./modules/rbac"
  
  organization = var.tfe_organization
  
  team = {
    name        = var.admin_team.name
    description = var.admin_team.description
    admins      = var.admin_team.admins
    members     = var.admin_team.members
    organization_access = {
      manage_workspaces = true
      manage_policies   = true
      manage_vcs        = true
      manage_modules    = true
      manage_providers  = true
      manage_run_tasks  = true
      manage_membership = true
    }
  }
}

# Create admin projects for platform management
resource "tfe_project" "admin_projects" {
  for_each     = { for p in var.admin_projects : p.name => p }
  
  name         = each.value.name
  organization = var.tfe_organization
  description  = each.value.description
}

# Assign admin team to admin projects with appropriate permissions
resource "tfe_team_project_access" "admin_project_access" {
  for_each     = { for p in var.admin_projects : p.name => p }
  
  team_id      = module.admin_team.team_id
  project_id   = tfe_project.admin_projects[each.key].id
  access       = "admin"
}

###################################################
# Platform Variable Sets
###################################################

# Create platform-level variable sets for each platform (vSphere, AWS, Azure)
module "platform_varsets" {
  source         = "./modules/variable-sets"
  organization   = var.tfe_organization
  
  vsphere_config = var.vsphere_config
  aws_config     = var.aws_config  # This is now just the global default config
  azure_config   = var.azure_config
}

###################################################
# Team Onboarding
###################################################

# For each team in teams variable, create necessary projects and workspace structure
module "team_onboarding" {
  source         = "./modules/team-foundation"
  
  for_each       = var.teams
  
  organization   = var.tfe_organization
  team_config    = each.value
  environments   = each.value.environments != null ? each.value.environments : ["dev", "preprod", "prod"]
  platforms      = each.value.platforms
  
  # Pass environment-specific configurations
  environment_configs = var.environment_configs
  
  # Pass platform variable set IDs
  platform_varset_ids = {
    vsphere = contains(each.value.platforms, "vsphere") ? (module.platform_varsets.vsphere_varset_id != null ? module.platform_varsets.vsphere_varset_id : "") : ""
    aws     = contains(each.value.platforms, "aws") ? (module.platform_varsets.aws_varset_id != null ? module.platform_varsets.aws_varset_id : "") : ""
    azure   = contains(each.value.platforms, "azure") ? (module.platform_varsets.azure_varset_id != null ? module.platform_varsets.azure_varset_id : "") : ""
  }
  
  # Pass team-specific platform configurations per environment
  aws_team_config    = lookup(each.value, "aws_config", null)
  azure_team_config  = lookup(each.value, "azure_config", null)
  vsphere_team_config = lookup(each.value, "vsphere_config", null)
  
  # Dependencies to ensure correct order of creation
  depends_on = [
    module.admin_team,
    module.platform_varsets
  ]
}

###################################################
# Workspace Creation
###################################################

# For each team, create workspaces in each environment for each platform
module "workspace_creation" {
  source = "./modules/workspace-factory"
  
  for_each = var.teams
  
  organization        = var.tfe_organization
  team_name           = each.value.name
  team_projects       = module.team_onboarding[each.key].project_ids
  environments        = each.value.environments != null ? each.value.environments : ["dev", "preprod", "prod"]
  platforms           = each.value.platforms
  environment_configs = var.environment_configs
  
  # Pass team-specific variables to be set at workspace level
  team_variables = {
    cost_code = each.value.cost_code
    team_email = each.value.email
  }
  
  # Pass team-specific platform configurations
  aws_team_config     = lookup(each.value, "aws_config", null)
  azure_team_config   = lookup(each.value, "azure_config", null)
  vsphere_team_config = lookup(each.value, "vsphere_config", null)
  
  # Dependencies to ensure projects are created first
  depends_on = [
    module.team_onboarding
  ]
}

###################################################
# Team Permission Management
###################################################

# Create and manage team permissions for each team
module "team_permissions" {
  source = "./modules/rbac"
  
  for_each     = var.teams
  
  organization = var.tfe_organization
  
  team = {
    name        = each.value.name
    description = "${each.value.name} team"
    admins      = each.value.admins
    members     = each.value.members
    organization_access = {
      manage_workspaces = false
      manage_policies   = false
      manage_vcs        = false
      manage_modules    = false
      manage_providers  = false
      manage_run_tasks  = false
      manage_membership = false
    }
  }
  
  # Assign team permissions to their projects
  project_access = {
    for env in (each.value.environments != null ? each.value.environments : ["dev", "preprod", "prod"]) :
    "${each.value.name}-${env}" => env == "prod" ? "maintain" : (env == "preprod" ? "write" : "admin")
  }
  
  depends_on = [
    module.team_onboarding
  ]
}

###################################################
# Team Workspace Access
###################################################

###################################################
# SSO Integration for Team Membership
###################################################

module "sso_integration" {
  source       = "./modules/sso-integration"
  organization = var.tfe_organization
  
  # Enable team management via SAML assertions
  enable_team_management    = var.enable_sso_team_management
  team_membership_attribute = var.sso_team_membership_attribute
  
  # Configure SSO based on the selected provider
  sso_configuration = var.sso_configuration
  
  # Map identity provider groups/roles to TFE teams
  teams = var.sso_team_mappings

  # Ensure this module runs after the organization is properly configured
  depends_on = [
    tfe_organization.org
  ]
} 