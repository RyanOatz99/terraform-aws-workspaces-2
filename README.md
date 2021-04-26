# terraform-aws-workspaces
A module for deploying WorkSpaces and related Directory, based on an input CSV file of desired users

Example Usage:

    module "workspaces" {
      source      = "terraform-aws-workspaces/"
      version     = "0.0.1"
      region      = "eu-west-2"
      environment = terraform.workspace == "default" ? "dev" : terraform.workspace

      project_owner = "[PROJECT_OWNER]"
      project_team  = "[PROJECT_TEAM]"

      name      = "[DEPLOYMENT_NAME]"
      bundle_id = "[BUNDLE_TO_USE_FOR_WORKSPACES]"

      s3_bucket_name = "[BUCKET_FOR_IAM_ACCESS]"

      enable_directory_logs = "true"

      directory_admin_password = "[REPLACE_WITH_PASSWORD]"
      directory_computer_ou    = "computers.workspaces.com"
      directory_domain_name    = "workspaces.com"

      winrm_instance_admin_password = "[REPLACE_WITH_PASSWORD]"
      winrm_pub_keyfile             = [PATH_TO_PUBLIC_KEY_FILE_FOR_WINRM]

      workspace_users_csv = [PATH_TO_CSV_FILE_OF_USERS]
      
      workspaces_client_types = {
        device_type_android    = "DENY"
        device_type_chromeos   = "DENY"
        device_type_ios        = "DENY"
        device_type_osx        = "DENY"
        device_type_web        = "ALLOW"
        device_type_windows    = "DENY"
        device_type_zeroclient = "DENY"
      }

      restricted_access_range = [
        "[LIST_OF_CIDRS_TO_RESTRICT_ACCESS_TO]"
      ]
    }




CSV File strucuture

firstname,lastname,username,email
A,User,auser,a.user@ons.gov.uk
