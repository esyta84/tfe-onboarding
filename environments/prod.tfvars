# Production Environment Configuration

# Environment-specific configurations
environment_configs = {
  prod = {
    auto_apply                = false
    terraform_version         = "1.6.0"
    execution_mode            = "remote"
    terraform_working_dir     = ""
    speculative_enabled       = true
    allow_destroy_plan        = false
    file_triggers_enabled     = true
    trigger_prefixes          = []
    queue_all_runs            = true
    assessments_enabled       = true
    global_remote_state       = true
    run_operation_timeout     = 120
    workspace_name_prefix     = "prod-"
  }
}

# Platform-specific configurations for production environment
vsphere_config = {
  enabled     = true
  datacenter  = "dc-prod-01"
  cluster     = "cluster-prod-01"
  datastore   = "datastore-prod-01"
  network     = "network-prod-01"
  folder_path = "/vm/terraform-managed-prod"
}

aws_config = {
  enabled     = true
  region      = "us-west-2"
  account_id  = "123456789012"
  vpc_id      = "vpc-prod0123456789abcdef"
  subnet_ids  = ["subnet-prod0123456789abcdef0", "subnet-prod0123456789abcdef1"]
}

azure_config = {
  enabled         = true
  subscription_id = "00000000-0000-0000-0000-000000000002"
  resource_group  = "terraform-prod-resources"
  location        = "eastus"
  virtual_network = "terraform-prod-vnet"
  subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000002/resourceGroups/terraform-prod-resources/providers/Microsoft.Network/virtualNetworks/terraform-prod-vnet/subnets/default"
} 