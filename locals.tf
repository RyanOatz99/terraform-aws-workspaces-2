locals {
  name        = var.name
  environment = var.environment

  account = data.aws_caller_identity.current.account_id

  users = csvdecode(var.workspace_users_csv)

  common_tags = {
    Name        = local.name
    Environment = local.environment
    Application = local.name
    Terraform   = "true"
    Owner       = var.project_owner
    Team        = var.project_team
  }
}
