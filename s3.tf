resource "aws_s3_bucket" "workspaces_config" {
  bucket = "${lower(var.project_team)}-${local.name}-config"
  acl    = "private"
  tags   = merge(local.common_tags, { Name = local.name })

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.workspaces_config.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "workspaces_config" {
  bucket                  = aws_s3_bucket.workspaces_config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "workspaces_config" {
  description             = "This key is used to encrypt bucket objects in the config S3 bucket"
  deletion_window_in_days = 14
}

data "template_file" "user_keys" {
  for_each = { for user in aws_iam_access_key.iam_accesskeys : user.user => user }
  template = file("${path.module}/files/user_keys.tpl")
  vars = {
    username = each.value.user
    id       = each.value.id
    secret   = each.value.secret
  }
}

resource "aws_s3_bucket_object" "object" {
  for_each = { for user in aws_iam_access_key.iam_accesskeys : user.user => user }
  bucket   = aws_s3_bucket.workspaces_config.id
  key      = "user/${each.value.user}"
  content  = data.template_file.user_keys[each.key].rendered
}
