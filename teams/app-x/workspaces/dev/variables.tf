# Variables for App-X development environment

variable "organization" {
  description = "The name of the Terraform Enterprise organization"
  type        = string
}

variable "environment_configs" {
  description = "Configuration for different environments"
  type = map(object({
    auto_apply                = bool
    terraform_version         = string
    execution_mode            = string
    terraform_working_dir     = string
    speculative_enabled       = bool
    allow_destroy_plan        = bool
    file_triggers_enabled     = bool
    trigger_prefixes          = list(string)
    queue_all_runs            = bool
    assessments_enabled       = bool
    global_remote_state       = bool
    run_operation_timeout     = number
    workspace_name_prefix     = string
  }))
}

variable "cost_code" {
  description = "Cost code for the App-X team"
  type        = string
  default     = "CC-APP-X-456"
}

variable "team_email" {
  description = "Contact email for the App-X team"
  type        = string
  default     = "app-x-team@example.com"
}

variable "aws_account_id" {
  description = "AWS account ID for the development environment"
  type        = string
} 