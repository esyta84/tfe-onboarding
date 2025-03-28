output "vsphere_varset_id" {
  description = "ID of the vSphere variable set"
  value       = var.vsphere_config.enabled ? tfe_variable_set.vsphere[0].id : null
}

output "aws_varset_id" {
  description = "ID of the AWS variable set"
  value       = var.aws_config.enabled ? tfe_variable_set.aws[0].id : null
}

output "azure_varset_id" {
  description = "ID of the Azure variable set"
  value       = var.azure_config.enabled ? tfe_variable_set.azure[0].id : null
} 