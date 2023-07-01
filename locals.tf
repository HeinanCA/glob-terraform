locals {
  common_tags = {
    Company     = var.Company
    Project     = "${var.Company}-NewCI/CD"
    Environment = var.environment
    BillingCode = var.BillingCode
  }
  naming_prefix = "${var.Company}-${var.environment}"
  s3_bucket_name = lower("${local.naming_prefix}-${random_integer.s3_seed_generator.result}")
}

resource "random_integer" "s3_seed_generator" {
  min = 10000
  max = 99999
}
