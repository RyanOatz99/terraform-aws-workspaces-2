module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.current.names
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway      = true
  external_nat_ip_ids     = aws_eip.workspaces.*.id
  create_igw              = true
  map_public_ip_on_launch = false

  enable_s3_endpoint = true

  tags = merge(local.common_tags, { Name = local.name })

}

resource "aws_eip" "workspaces" {
  count = 3
  vpc   = true

  tags = merge(local.common_tags, { Name = local.name })
}
