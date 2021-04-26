variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "name" {
  type        = string
  default     = "workspaces"
  description = "The name for the deployment"
}

variable "bundle_id" {
  type        = string
  default     = "wsb-g8xzr18c9"
  description = "The Bundle ID to use as the basis for the WorkSpaces deployment"
}

variable "winrm_pub_keyfile" {
  type        = string
  default     = ""
  description = "Public key for use with the Windows Remote Manager Instance"
}

variable "cloudberry_external_id" {
  type        = string
  default     = "12345"
  description = "The external ID used to match CloudBerry Clients"
}

variable "project_owner" {
  type        = string
  default     = "PROJ_OWNER"
  description = "The identifier for the Project Owner"
}

variable "project_team" {
  type        = string
  default     = "PROJ_TEAM"
  description = "The identifier for the Project Team"
}

variable "workspace_users_csv" {
  type        = string
  default     = ""
  description = "Points to CSV file of users"
}

variable "restricted_access_range" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR range(s) to lock down WorkSpace access to"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "The name of the environment for deployment/tagging"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR range for use in the VPC"
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
  description = "A list of CIDRs for the Private Subnets"
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
  description = "A list of CIDRs for the Private Subnets"
}

variable "directory_domain_name" {
  type        = string
  default     = "workspaces.com"
  description = "The domain used for the WorkSpaces deployment"
}

variable "directory_computer_ou" {
  type        = string
  default     = "computers.workspaces.com"
  description = "The OU for computers to be placed in"
}

variable "directory_admin_password" {
  type        = string
  description = "Password for the Directory admin user"
}

variable "winrm_instance_admin_username" {
  type        = string
  description = "Username for the WinRM Instance admin user"
  default     = "Administrator"
}
variable "winrm_instance_admin_password" {
  type        = string
  description = "Password for the WinRM Instance admin user"
}

variable "s3_bucket_name" {
  type        = string
  description = "The S3 Bucket where user files are stored"
  default     = ""
}

variable "workspaces_client_types" {
  description = "For ALLOW or DENY of WorkSpaces Clients within the deployment"

  type = object({
    device_type_android    = string
    device_type_chromeos   = string
    device_type_ios        = string
    device_type_osx        = string
    device_type_web        = string
    device_type_windows    = string
    device_type_zeroclient = string
  })

  default = {
    device_type_android    = "DENY"
    device_type_chromeos   = "DENY"
    device_type_ios        = "DENY"
    device_type_osx        = "DENY"
    device_type_web        = "DENY"
    device_type_windows    = "DENY"
    device_type_zeroclient = "DENY"
  }
}

variable "enable_directory_logs" {
  description = "True if the Directory Logging should be enabled."
  default     = "false"
  type        = string
}

variable "directory_logs_name_prefix" {
  description = "The CW LogGroup for Directory Logs"
  default     = "/aws/directoryservice"
  type        = string
}
