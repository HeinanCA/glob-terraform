# aws_elb_service_account
data "aws_elb_service_account" "main" {}

# there goes aws_lb
resource "aws_lb" "nginx_lb" {
  name               = "global-nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_elb_sg.id]
  subnets            = module.app.public_subnets
  depends_on         = [module.s3_module.s3_bucket]

  enable_deletion_protection = false

  access_logs {
    bucket  = module.s3_module.s3_bucket.id
    enabled = true
    prefix  = "nginx-lb"
  }

  tags = merge(local.common_tags, {
    Name = "${local.naming_prefix}-nginx-lb"
  })
}

# there goes aws_lb_target_group
resource "aws_lb_target_group" "nginx_lb_tg" {
  name     = "global-nginx-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.app.vpc_id
}
# there goes aws_lb_listener
resource "aws_lb_listener" "nginx_lb_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.nginx_lb_tg.arn
    type             = "forward"
  }
}

# there goes aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "nginx_lb_tg_attachment_one" {
  count            = var.num_of_public_subnets
  target_group_arn = aws_lb_target_group.nginx_lb_tg.arn
  target_id        = aws_instance.web_servers[count.index].id
  port             = 80
}
