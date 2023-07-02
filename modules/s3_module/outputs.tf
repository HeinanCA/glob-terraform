# web_bucket
output "s3_bucket" {
  value       = aws_s3_bucket.s3
  description = "The S3 bucket as object"
}
# instance_profile
output "s3_instance_profile" {
  value       = aws_iam_instance_profile.nginx_profile
  description = "The S3 instance profile as object"
}