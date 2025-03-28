variable "organization" {
  description = "The name of the TFE organization"
  type        = string
}

variable "team" {
  description = "Team configuration for creation and permissions"
  type = object({
    name        = string
    description = string
    admins      = list(string)
    members     = list(string)
    organization_access = object({
      manage_workspaces = bool
      manage_policies   = bool
      manage_vcs        = bool
      manage_modules    = bool
      manage_providers  = bool
      manage_run_tasks  = bool
      manage_membership = bool
    })
  })
}

variable "project_access" {
  description = "Map of project names to access levels (read, write, maintain, admin)"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for access in values(var.project_access) : 
      contains(["read", "write", "maintain", "admin"], access)
    ])
    error_message = "Project access must be one of: read, write, maintain, admin."
  }
}

variable "workspace_access" {
  description = "Map of workspace names to access levels (read, plan, write, admin)"
  type        = map(string)
  default     = {}
  
  validation {
    condition = alltrue([
      for access in values(var.workspace_access) : 
      contains(["read", "plan", "write", "admin"], access)
    ])
    error_message = "Workspace access must be one of: read, plan, write, admin."
  }
} 