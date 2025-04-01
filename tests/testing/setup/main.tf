# Test prerequisites setup

resource "tfe_team" "admin_team" {
  name         = "admins-test"
  organization = var.tfe_organization
}

resource "tfe_team" "user_team" {
  name         = "users-test"
  organization = var.tfe_organization
}

variable "tfe_organization" {
  description = "The name of the TFE organization"
  type        = string
} 