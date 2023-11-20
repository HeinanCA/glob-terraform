# DATA #
data "aws_availability_zones" "available" {
  state = "available"
}

# RESOURCES

# NETWORK #
module "app" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  cidr = var.vpc_cidr_block
  azs  = slice(data.aws_availability_zones.available.names, 0, var.num_of_public_subnets)

  public_subnets = [for subnet in range(var.num_of_public_subnets) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  map_public_ip_on_launch = var.map_public_ip_on_launch
  enable_dns_hostnames    = var.enable_dns_hostnames

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-vpc" })
}

# SECURITY GROUPS FOR ELB #
resource "aws_security_group" "nginx_elb_sg" {
  name        = "${local.naming_prefix}-nginx-elb-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = module.app.vpc_id
  tags        = local.common_tags
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SECURITY GROUPS #
resource "aws_security_group" "nginx" {
  name        = "${local.naming_prefix}-nginx-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = module.app.vpc_id
  tags        = local.common_tags
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
