provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.aws_region[0]
}

data "aws_ssm_parameter" "amzn2_linux" {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# RESOURCES

# NETWORK #
resource "aws_vpc" "app" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames
}

resource "aws_internet_gateway" "app" {
    vpc_id = aws_vpc.app.id
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.app.id
    cidr_block = var.subnet_cidr_block
    map_public_ip_on_launch = var.map_public_ip_on_launch
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.app.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app.id
    }
}

resource "aws_route_table_association" "public_route_table_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

# SECURITY GROUPS #
resource "aws_security_group" "nginx" {
    name = "nginx"
    description = "Allow HTTP and SSH inbound traffic"
    vpc_id = aws_vpc.app.id
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# EC2 #
resource "aws_instance" "my_instance" {
    ami = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
    instance_type = var.instance_sizes["micro"]
    vpc_security_group_ids = [aws_security_group.nginx.id]
    subnet_id = aws_subnet.public_subnet.id
    associate_public_ip_address = true
    tags = {
        Name = "my_instance"
    }
    
    user_data = <<-EOF
        #!/bin/bash
        sudo amazon-linux-extras install -y nginx1
        sudo service nginx start
        sudo rm /usr/share/nginx/html/index.html
        echo '<html><head><title>Taco Team Server</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
    EOF  
}