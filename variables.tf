variable "aws_access_key" {
  type        = string
  description = "Our AWS access key"
  sensitive   = true
}

variable "Company" {
  type        = string
  description = "Company name for the instance"
}

variable "BillingCode" {
  type        = string
  description = "Billing code for the instance (resouce tagging)"
}

variable "aws_secret_key" {
  type        = string
  description = "Our AWS secret key"
  sensitive   = true
}

variable "aws_regions" {
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
  description = "AWS region to deploy resources"
}

variable "instance_sizes" {
  type = map(string)
  default = {
    micro  = "t3.micro"
    small  = "t3.small"
    medium = "t3.medium"
    large  = "t3.large"
  }
  description = "AWS instance size"
}

variable "vpc_cidr_block" {
  type        = string
  description = "value of the VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "enable DNS hostnames?"
  default     = true
}

variable "subnets_cidr_block" {
  type        = list(string)
  description = "value of the Public Subnets CIDR block"
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "map public IP on launch?"
  default     = true
}

variable "num_of_public_subnets" {
  type        = number
  description = "How many subnets would you like?"
  default     = 2
}

variable "num_of_instances" {
  type        = number
  description = "How many EC2 instances would you like?"
  default     = 2
}

variable "naming_prefix" {
  type        = string
  description = "value of the naming prefix"
  default     = "HeinanCA-dev"
}

variable "environment" {
  type        = string
  description = "Which environment is this?"
  default     = "prod"
}