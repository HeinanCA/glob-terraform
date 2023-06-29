output "public_dns_hostname" {
  value       = "http://${aws_instance.web_server.public_dns}"
  description = "Our NGINX server's public DNS hostname"
}