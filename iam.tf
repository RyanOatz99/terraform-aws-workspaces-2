data "aws_iam_policy_document" "workspaces" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["workspaces.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workspaces" {
  name               = "workspaces_DefaultRole"
  assume_role_policy = data.aws_iam_policy_document.workspaces.json
}

resource "aws_iam_role_policy_attachment" "workspaces_default_service_access" {
  role       = aws_iam_role.workspaces.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"
}

resource "aws_iam_role_policy_attachment" "workspaces_default_self_service_access" {
  role       = aws_iam_role.workspaces.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}

data "aws_iam_policy_document" "winrm" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "winrm" {
  name               = "WinRMforWorkSpaces"
  assume_role_policy = data.aws_iam_policy_document.winrm.json
}

resource "aws_iam_instance_profile" "winrm" {
  name = "winrm"
  role = aws_iam_role.winrm.name
}

resource "aws_iam_role_policy_attachment" "workspaces_config_bucket_access" {
  role       = aws_iam_role.winrm.name
  policy_arn = aws_iam_policy.workspaces_config_bucket_access.arn
}

resource "aws_iam_policy" "workspaces_config_bucket_access" {
  name   = "WorkspacesConfigBucketAccess"
  path   = "/workspaces/"
  policy = data.aws_iam_policy_document.workspaces_config_bucket_access.json
}

data "aws_iam_policy_document" "workspaces_config_bucket_access" {
  statement {
    sid    = "AllowBucketAccess"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.workspaces_config.arn
    ]
  }
}

resource "aws_iam_policy" "cloudberry_s3_access" {
  name   = "CloudberryS3AccessPolicy"
  path   = "/workspaces/"
  policy = data.aws_iam_policy_document.cloudberry_s3_access.json
}

data "aws_iam_policy_document" "cloudberry_s3_access" {
  statement {
    sid    = "AllowBucketAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]
  }
  statement {
    sid    = "AllowObjectAccess"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectVersionAcl",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*.xml",
      "arn:aws:s3:::${var.s3_bucket_name}/*.txt",
      "arn:aws:s3:::${var.s3_bucket_name}/*.csv",
      "arn:aws:s3:::${var.s3_bucket_name}/*.xlsx",
      "arn:aws:s3:::${var.s3_bucket_name}/*.txt.gz",
      "arn:aws:s3:::${var.s3_bucket_name}/*.parquet",
      "arn:aws:s3:::${var.s3_bucket_name}/*.mani"
    ]
  }
}

data "aws_iam_policy_document" "cloudberry_assume_role" {
  statement {
    sid     = "AllowAssumeCloudBerryRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      values   = [var.cloudberry_external_id]
      variable = "sts:ExternalId"
    }
    principals {
      identifiers = [
        for user in aws_iam_user.iam_users :
        user.arn
      ]
      type = "AWS"
    }
  }
}

data "aws_iam_policy_document" "user_allowed_assume_cloudberry_role" {
  statement {
    sid     = "AllowUserAssumeCloudBerryRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${local.account}:role/${aws_iam_role.cloudberry_assume_role.name}"
      ]
      type = "AWS"
    }
  }
}

resource "aws_iam_role" "cloudberry_assume_role" {
  name               = "CloudBerryAssumeRole"
  description        = "Cloudberry Role for Assuming"
  assume_role_policy = data.aws_iam_policy_document.cloudberry_assume_role.json
}

resource "aws_iam_user" "iam_users" {
  for_each      = { for user in local.users : user.username => user }
  name          = each.value.username
  path          = "/${var.name}/"
  force_destroy = true
  tags          = merge(local.common_tags, { Name = local.name })
}

resource "aws_iam_access_key" "iam_accesskeys" {
  for_each   = { for user in aws_iam_user.iam_users : user.name => user }
  user       = each.value.name
  depends_on = [aws_iam_user.iam_users]
}

resource "aws_iam_role_policy_attachment" "cloudberry_s3_access" {
  policy_arn = aws_iam_policy.cloudberry_s3_access.arn
  role       = aws_iam_role.cloudberry_assume_role.name
}

//output "users_info" {
//  description = "A map of each user's credentials"
//  value = zipmap(keys(aws_iam_access_key.iam_accesskeys)[*], values(aws_iam_access_key.iam_accesskeys)[*])
//  sensitive = true
//}
