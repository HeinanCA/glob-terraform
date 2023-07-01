locals {
  common_tags = {
    Company     = var.Company
    Project     = "${var.Company}-NewCI/CD"
    BillingCode = var.BillingCode
  }

  s3_bucket_name = "${var.Company}-new-cicd-${random_integer.s3_seed_generator.result}"
}

resource "random_integer" "s3_seed_generator" {
  min = 10000
  max = 99999
}
