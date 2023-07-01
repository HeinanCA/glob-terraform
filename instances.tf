
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 in Subnet one #
resource "aws_instance" "web_server_one" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_sizes["micro"]
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  subnet_id                   = aws_subnet.public_subnet_one.id
  associate_public_ip_address = true
  tags = {
    Name        = "HeinanAwesomeInstance"
    Company     = local.common_tags.Company
    Project     = local.common_tags.Project
    BillingCode = local.common_tags.BillingCode
  }

  user_data = <<-EOF
        #!/bin/bash
        sudo amazon-linux-extras install -y nginx1
        sudo service nginx start
        sudo rm /usr/share/nginx/html/index.html
        echo '<html><head><title>Taco Team Server One</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
    EOF  
}

# EC2 in Subnet two #
resource "aws_instance" "web_server_two" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_sizes["micro"]
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  subnet_id                   = aws_subnet.public_subnet_two.id
  associate_public_ip_address = true
  tags = {
    Name        = "HeinanAwesomeInstance"
    Company     = local.common_tags.Company
    Project     = local.common_tags.Project
    BillingCode = local.common_tags.BillingCode
  }

  user_data = <<-EOF
        #!/bin/bash
        sudo amazon-linux-extras install -y nginx1
        sudo service nginx start
        sudo rm /usr/share/nginx/html/index.html
        echo '<html><head><title>Taco Team Server Two</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
    EOF  
}

# aws_iam_role
resource "aws_iam_role" "s3_role" {
  name = "s3_website_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "s3.amazonaws.com"
        }
      },
    ]
  })
}

# aws_iam_role_policy
resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_website_policy"
  role = aws_iam_role.s3_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${data.aws_elb_service_account.main.arn}"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}/nginx-lb/*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}/nginx-lb/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}"
      }
    ]
  })
}

# aws_iam_instance_profile
resource "aws_iam_instance_profile" "s3_profile" {
  name = "s3_profile"
  role = aws_iam_role.s3_role.name
}
