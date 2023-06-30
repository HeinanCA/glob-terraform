output "public_load_balancer_dns" {
  value       = "http://${aws_lb.nginx_lb.dns_name}"
  description = "Our NGINX server's public DNS hostname (behind the load balancer!)"
}