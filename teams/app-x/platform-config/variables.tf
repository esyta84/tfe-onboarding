variable "environments" {
  description = "List of environments to deploy (e.g. dev, preprod, prod)"
  type        = list(string)
  default     = ["dev", "preprod", "prod"]
}

variable "cost_code" {
  description = "Cost center code for resource tagging"
  type        = string
}

variable "team_email" {
  description = "Team email for resource tagging and contact information"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID used for globally unique naming"
  type        = string
} 