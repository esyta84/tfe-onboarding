# AWS platform configuration for App-X team

# Define common AWS resources across environments
locals {
  aws_regions = {
    dev     = "us-west-2"
    preprod = "us-west-2"
    prod    = "us-east-1"  # Production uses a different region
  }
  
  aws_tags = {
    Team       = "app-x"
    ManagedBy  = "terraform"
    CostCode   = var.cost_code
    Contact    = var.team_email
  }
}

# VPC configurations for different environments
module "aws_vpc" {
  source = "../../../modules/aws-vpc"  # Example module
  
  for_each = toset(var.environments)
  
  name            = "app-x-${each.key}-vpc"
  cidr            = each.key == "prod" ? "10.1.0.0/16" : "10.0.0.0/16"
  region          = local.aws_regions[each.key]
  azs             = [for i in range(3) : "${local.aws_regions[each.key]}${["a", "b", "c"][i]}"]
  private_subnets = each.key == "prod" ? ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] : ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = each.key == "prod" ? ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"] : ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  tags = merge(local.aws_tags, {
    Environment = each.key
  })
}

# S3 bucket for team assets
resource "aws_s3_bucket" "app_x_assets" {
  for_each = toset(var.environments)
  
  bucket = "app-x-${each.key}-assets-${var.aws_account_id}"
  
  tags = merge(local.aws_tags, {
    Environment = each.key
    Name        = "app-x-${each.key}-assets"
  })
} 