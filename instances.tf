
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 in Subnet one #
resource "aws_instance" "web_servers" {
  count                       = var.num_of_instances
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_sizes["micro"]
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  iam_instance_profile        = aws_iam_instance_profile.nginx_profile.name
  subnet_id                   = aws_subnet.public_subnets[(count.index % var.num_of_public_subnets)].id
  associate_public_ip_address = true
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-ec2-${count.index}"
  })

  depends_on = [aws_iam_role_policy.allow_s3_all]

  user_data = templatefile("${path.module}/templates/startup_code.sh", {
    s3_bucket_name = aws_s3_bucket.s3.id
  })
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
