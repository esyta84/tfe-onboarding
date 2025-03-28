terraform {
  required_version = ">= 1.0.0"
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.tfe_token
}

# Configure additional providers for potential utility functions
provider "random" {} 