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
    device_type_android    = var.workspaces_client_types.device_type_android
    device_type_chromeos   = var.workspaces_client_types.device_type_chromeos
    device_type_ios        = var.workspaces_client_types.device_type_ios
    device_type_osx        = var.workspaces_client_types.device_type_osx
    device_type_web        = var.workspaces_client_types.device_type_web
    device_type_windows    = var.workspaces_client_types.device_type_windows
    device_type_zeroclient = var.workspaces_client_types.device_type_zeroclient
  }

  workspace_creation_properties {
    custom_security_group_id            = aws_security_group.workspaces.id
    default_ou                          = ""
    enable_internet_access              = false
    enable_maintenance_mode             = true
    user_enabled_as_local_administrator = false

  }
}

resource "aws_cloudwatch_log_group" "workspaces" {
  count = var.enable_directory_logs == "true" ? 1 : 0

  name              = "${var.directory_logs_name_prefix}/${aws_directory_service_directory.workspaces.id}"
  retention_in_days = 1
}

data "aws_iam_policy_document" "ad-log-policy" {
  count = var.enable_directory_logs == "true" ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    principals {
      identifiers = ["ds.amazonaws.com"]
      type        = "Service"
    }

    resources = ["${aws_cloudwatch_log_group.workspaces[0].arn}:*"]

    effect = "Allow"
  }
}

resource "aws_cloudwatch_log_resource_policy" "ad-log-policy" {
  count = var.enable_directory_logs == "true" ? 1 : 0

  policy_document = data.aws_iam_policy_document.ad-log-policy[0].json
  policy_name     = "ad-log-policy"
}

resource "aws_directory_service_log_subscription" "workspaces" {
  count = var.enable_directory_logs == "true" ? 1 : 0

  directory_id   = aws_directory_service_directory.workspaces.id
  log_group_name = aws_cloudwatch_log_group.workspaces[0].name
}
