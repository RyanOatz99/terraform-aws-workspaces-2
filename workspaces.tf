data "aws_workspaces_bundle" "workspaces" {
  bundle_id = var.bundle_id
}

resource "aws_kms_key" "workspaces_user_volumes" {
  description             = "${local.name} - User Volume Encryption Key"
  deletion_window_in_days = 14
  is_enabled              = true
  enable_key_rotation     = true
  tags                    = merge(local.common_tags, { Name = "cognito_audit_kms", "ProtectSensitiveData" = "True" })
}

resource "aws_kms_alias" "workspaces_user_volumes" {
  name          = "alias/${local.name}-user-volumes"
  target_key_id = aws_kms_key.workspaces_user_volumes.key_id
}

resource "aws_workspaces_workspace" "workspaces" {
  for_each     = { for user in aws_iam_user.iam_users : user.name => user }
  directory_id = aws_workspaces_directory.workspaces.id
  bundle_id    = data.aws_workspaces_bundle.workspaces.bundle_id
  user_name    = each.value.name

  user_volume_encryption_enabled = true
  volume_encryption_key          = aws_kms_key.workspaces_user_volumes.arn

  workspace_properties {
    compute_type_name                         = "STANDARD"
    user_volume_size_gib                      = 100
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = merge(local.common_tags, { Name = local.name })

  depends_on = [aws_iam_user.iam_users]
}

resource "aws_workspaces_ip_group" "main" {
  name        = "main"
  description = "IP Access Control"

  rules {
    source      = module.vpc.vpc_cidr_block
    description = "VPC internal"
  }

  dynamic "rules" {
    for_each = var.restricted_access_range
    content {
      source      = rules.value
      description = "Restricted Access Range Rule"
    }
  }
}
