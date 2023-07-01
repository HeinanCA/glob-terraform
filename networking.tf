# DATA #
data "aws_availability_zones" "available" {
  state = "available"
}

# RESOURCES

# NETWORK #
resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = merge(local.common_tags, { Name = "${local.naming_prefix}-vpc" })
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = local.common_tags
}

resource "aws_subnet" "public_subnets" {
  count                   = var.num_of_public_subnets
  vpc_id                  = aws_vpc.app.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = local.common_tags
  availability_zone       = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
  tags = local.common_tags
}

resource "aws_route_table_association" "public_route_table_associations" {
  count          = var.num_of_public_subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# SECURITY GROUPS FOR ELB #
resource "aws_security_group" "nginx_elb_sg" {
  name        = "${local.naming_prefix}-nginx-elb-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.app.id
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
  vpc_id      = aws_vpc.app.id
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
