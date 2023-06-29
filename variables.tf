variable "aws_access_key" {
    type = string
    description = "Our AWS access key"
    sensitive = true
}

variable "aws_secret_key" {
    type = string
    description = "Our AWS secret key"
    sensitive = true
}

variable "aws_regions" {
    type = list(string)
    default = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
    description = "AWS region to deploy resources"  
}

variable "instance_sizes" {
    type = map(string)
    default = {
        micro = "t3.micro"
        small = "t3.small"
        medium = "t3.medium"
        large = "t3.large"
    }
    description = "AWS instance size"  
}

variable "vpc_cidr_block" {
    type = string
    description = "value of the VPC CIDR block"
    default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
    type = bool
    description = "enable DNS hostnames?"
    default = true
}

variable "subnet_cidr_block" {
    type = string
    description = "value of the subnet CIDR block"
    default = "10.0.0.0/24"
}

variable "map_public_ip_on_launch" {
    type = bool
    description = "map public IP on launch?"
    default = true
}