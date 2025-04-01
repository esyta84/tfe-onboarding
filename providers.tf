terraform {
  required_version = ">= 1.0.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.64.0"
    }
    # Removed unused random provider - uncomment if needed for future requirements
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.5.0"
    # }
  }
}

provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.tfe_token
}

# Provider declarations should only be included if used in the codebase
# Uncomment if random values are needed in the future
# provider "random" {} 