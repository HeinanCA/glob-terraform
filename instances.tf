
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# EC2 in Subnet one #
resource "aws_instance" "web_servers" {
  count                       = var.num_of_instances
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_sizes["micro"]
  vpc_security_group_ids      = [aws_security_group.nginx.id]
  iam_instance_profile        = module.s3_module.s3_instance_profile.id
  subnet_id                   = module.app.public_subnets[(count.index % var.num_of_public_subnets)]
  associate_public_ip_address = true
  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-ec2-${count.index}"
  })

  depends_on = [module.s3_module]

  user_data = templatefile("${path.module}/templates/startup_code.sh", {
    s3_bucket_name = module.s3_module.s3_bucket.id
  })
}