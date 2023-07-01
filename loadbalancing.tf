# aws_elb_service_account
data "aws_elb_service_account" "main" {}

# there goes aws_lb
resource "aws_lb" "nginx_lb" {
  name               = "global-nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_elb_sg.id]
  subnets            = [aws_subnet.public_subnet_one.id, aws_subnet.public_subnet_two.id]
  depends_on         = [aws_s3_bucket.s3]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.s3.bucket
    enabled = true
    prefix  = "nginx-lb"
  }

  tags = local.common_tags
}

# there goes aws_lb_target_group
resource "aws_lb_target_group" "nginx_lb_tg" {
  name     = "global-nginx-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id
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
  target_group_arn = aws_lb_target_group.nginx_lb_tg.arn
  target_id        = aws_instance.web_server_one.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx_lb_tg_attachment_two" {
  target_group_arn = aws_lb_target_group.nginx_lb_tg.arn
  target_id        = aws_instance.web_server_two.id
  port             = 80
}
