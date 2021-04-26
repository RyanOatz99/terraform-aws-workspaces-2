resource "aws_fsx_windows_file_system" "windows_fsx" {

  active_directory_id = aws_directory_service_directory.workspaces.id
  storage_capacity    = 300
  subnet_ids          = [module.vpc.private_subnets[0]]
  security_group_ids  = [aws_security_group.adwriter.id]
  throughput_capacity = 8
  //  deployment_type     = "SINGLE_AZ_2"
  storage_type = "SSD"

  tags = merge(local.common_tags, { Name = local.name })
}
