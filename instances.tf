
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 in Subnet one #
resource "aws_instance" "web_server_one" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_sizes["micro"]
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  iam_instance_profile        = aws_iam_instance_profile.nginx_profile.name
  subnet_id                   = aws_subnet.public_subnet_one.id
  associate_public_ip_address = true
  tags = {
    Name        = "HeinanAwesomeInstance"
    Company     = local.common_tags.Company
    Project     = local.common_tags.Project
    BillingCode = local.common_tags.BillingCode
  }

  depends_on = [aws_iam_role_policy.allow_s3_all]

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello from AWS!"
        sudo amazon-linux-extras install -y nginx1
        sudo service nginx start
        aws s3 cp s3://${aws_s3_bucket.s3.id}/index.html /home/ec2-user/index.html
        aws s3 cp s3://${aws_s3_bucket.s3.id}/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
        sudo rm /usr/share/nginx/html/index.html
        sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
        sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
    EOF  
}

# EC2 in Subnet two #
resource "aws_instance" "web_server_two" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_sizes["micro"]
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  iam_instance_profile        = aws_iam_instance_profile.nginx_profile.name
  subnet_id                   = aws_subnet.public_subnet_two.id
  associate_public_ip_address = true
  tags = {
    Name        = "HeinanAwesomeInstance"
    Company     = local.common_tags.Company
    Project     = local.common_tags.Project
    BillingCode = local.common_tags.BillingCode
  }

  depends_on = [aws_iam_role_policy.allow_s3_all]

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello from AWS!"
        sudo amazon-linux-extras install -y nginx1
        sudo service nginx start
        aws s3 cp s3://${aws_s3_bucket.s3.id}/index.html /home/ec2-user/index.html
        aws s3 cp s3://${aws_s3_bucket.s3.id}/Globo_logo_Vert.png /home/ec2-user/Globo_logo_Vert.png
        sudo rm /usr/share/nginx/html/index.html
        sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html
        sudo cp /home/ec2-user/Globo_logo_Vert.png /usr/share/nginx/html/Globo_logo_Vert.png
    EOF  
}

# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
    }
  ]
}
EOF

}
