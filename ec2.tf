data "aws_ami" "winrm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

resource "aws_key_pair" "winrm" {
  key_name   = "winrm"
  public_key = var.winrm_pub_keyfile
}

resource "aws_instance" "winrm" {
  ami           = data.aws_ami.winrm.image_id
  instance_type = "t2.micro"
  //  iam_instance_profile = aws_iam_instance_profile.winrm.name

  connection {
    type     = "winrm"
    user     = var.winrm_instance_admin_username
    password = var.winrm_instance_admin_password
    timeout  = "10m"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 40
    delete_on_termination = true
  }

  get_password_data           = true
  availability_zone           = module.vpc.azs[0]
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = false
  vpc_security_group_ids = [
    aws_security_group.workspaces.id,
    aws_security_group.adwriter.id
  ]
  key_name = aws_key_pair.winrm.key_name

  user_data = templatefile(
    "${path.module}/files/userdata.tpl",
    {
      winrm_instance_admin_username = var.winrm_instance_admin_username
      winrm_instance_admin_password = var.winrm_instance_admin_password
      directory_domain_name         = var.directory_domain_name
      dns_ip_addresses              = aws_directory_service_directory.workspaces.dns_ip_addresses
    }
  )

  tags = merge(local.common_tags, { Name = "Workspaces EC2 AD (WinRM)" })
}
