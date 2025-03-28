# main.tf for App-X team

terraform {
  required_version = ">= 1.0.0"
  
  # Configure remote backend (adjust as needed)
  backend "remote" {
    organization = "your-tfe-org"
    
    workspaces {
      name = "app-x-onboarding"
    }
  }
}

# Include the root module to onboard only this team
module "app_x_onboarding" {
  source = "../../"  # Root module
  
  # Only include this team 
  teams = {
    "app-x" = var.teams["app-x"]
  }
  
  # Team-specific SSO mappings
  sso_team_mappings = var.sso_team_mappings
  
  # Add the required authentication token
  tfe_token = var.tfe_token
  
  # Re-use other global variables from the root module
  tfe_organization        = var.tfe_organization
  tfe_org_email           = var.tfe_org_email
  environment_configs     = var.environment_configs
  vsphere_config          = var.vsphere_config
  aws_config              = var.aws_config
  azure_config            = var.azure_config
  enable_sso_team_management = var.enable_sso_team_management
  sso_team_membership_attribute = var.sso_team_membership_attribute
  sso_configuration       = var.sso_configuration
  
  # Admin team configuration is still needed since it's referenced by the root module
  admin_team              = var.admin_team
  admin_projects          = var.admin_projects
} 
