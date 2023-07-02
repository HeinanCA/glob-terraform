# bucket_name
variable "aws_s3_bucket" {
  type        = string
  description = "Name of the S3 bucket"
}
# elb_service_account_arn
variable "elb_service_account_arn" {
  type        = string
  description = "ARN of the ELB service account"
}
# common_tags
variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}
