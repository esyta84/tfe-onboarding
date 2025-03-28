# Development environment resources for App-X

terraform {
  required_version = ">= 1.0.0"
  
  # Configure remote backend
  backend "remote" {
    organization = "your-tfe-org"
    
    workspaces {
      name = "app-x-dev"
    }
  }
}

# AWS resources for App-X development environment
module "app_x_aws_infrastructure" {
  source = "../../../../modules/workspace-factory"
  
  organization  = var.organization
  team_name     = "app-x"
  platforms     = ["aws"]
  environments  = ["dev"]
  
  # Add the required team_projects attribute
  team_projects = {
    "dev" = "app-x-dev-project-id"  # Replace with actual project ID or reference
  }
  
  # Use only dev environment configuration
  environment_configs = {
    dev = var.environment_configs["dev"]
  }
  
  # Team-specific variables for the development workspace
  team_variables = {
    cost_code = var.cost_code
    team_email = var.team_email
    environment = "development"
    is_production = false
  }
}

# Custom resources specific to App-X development environment
resource "aws_s3_bucket" "app_x_dev_data" {
  bucket = "app-x-dev-data-${var.aws_account_id}"
  
  tags = {
    Name        = "app-x-dev-data"
    Environment = "dev"
    Team        = "app-x"
    ManagedBy   = "terraform"
  }
}

resource "aws_dynamodb_table" "app_x_dev_state" {
  name           = "app-x-dev-state"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "app-x-dev-state"
    Environment = "dev"
    Team        = "app-x"
    ManagedBy   = "terraform"
  }
} 