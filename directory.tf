resource "aws_directory_service_directory" "workspaces" {
  name     = var.directory_domain_name
  password = var.directory_admin_password
  size     = "Small"
  type     = "MicrosoftAD"
  edition  = "Standard"

  vpc_settings {
    subnet_ids = module.vpc.private_subnets
    vpc_id     = module.vpc.vpc_id
  }
}

resource "aws_workspaces_directory" "workspaces" {
  directory_id = aws_directory_service_directory.workspaces.id
  subnet_ids   = module.vpc.private_subnets

  tags = merge(local.common_tags, { Name = local.name })

  self_service_permissions {
    change_compute_type  = true
    increase_volume_size = true
    rebuild_workspace    = true
    restart_workspace    = true
    switch_running_mode  = true
  }

  workspace_access_properties {
    device_type_web = "ALLOW"
  }

  workspace_creation_properties {
    custom_security_group_id            = aws_security_group.workspaces.id
    default_ou                          = ""
    enable_internet_access              = false
    enable_maintenance_mode             = true
    user_enabled_as_local_administrator = false

  }
}
