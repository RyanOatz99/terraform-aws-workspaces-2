resource "aws_security_group" "workspaces" {
  vpc_id      = module.vpc.vpc_id
  name        = local.name
  description = "For use with ${local.name}"

  tags = merge(local.common_tags, { Name = local.name })
}

resource "aws_security_group" "adwriter" {
  vpc_id = module.vpc.vpc_id
  name   = "${local.name} Directory Writer"
  ingress {
    from_port   = 1
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = local.name })
}
