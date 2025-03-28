# Dev Environment Configuration

# Environment-specific configurations
environment_configs = {
  dev = {
    auto_apply                = true
    terraform_version         = "1.6.0"
    execution_mode            = "remote"
    terraform_working_dir     = ""
    speculative_enabled       = true
    allow_destroy_plan        = true
    file_triggers_enabled     = true
    trigger_prefixes          = []
    queue_all_runs            = false
    assessments_enabled       = false
    global_remote_state       = false
    run_operation_timeout     = 30
    workspace_name_prefix     = "dev-"
  }
}

# Platform-specific configurations for dev environment
vsphere_config = {
  enabled     = true
  datacenter  = "dc-dev-01"
  cluster     = "cluster-dev-01"
  datastore   = "datastore-dev-01"
  network     = "network-dev-01"
  folder_path = "/vm/terraform-managed-dev"
}

aws_config = {
  enabled     = true
  region      = "us-west-2"
  account_id  = "123456789012"
  vpc_id      = "vpc-dev0123456789abcdef"
  subnet_ids  = ["subnet-dev0123456789abcdef0", "subnet-dev0123456789abcdef1"]
}

azure_config = {
  enabled         = true
  subscription_id = "00000000-0000-0000-0000-000000000000"
  resource_group  = "terraform-dev-resources"
  location        = "eastus"
  virtual_network = "terraform-dev-vnet"
  subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/terraform-dev-resources/providers/Microsoft.Network/virtualNetworks/terraform-dev-vnet/subnets/default"
} 