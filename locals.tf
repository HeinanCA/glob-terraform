locals {
  common_tags = {
    Company     = var.Company
    Project     = "${var.Company}-NewCI/CD"
    BillingCode = var.BillingCode
  }
}

resource "random_integer" "s3_seed_generator" {
  min = 10000
  max = 99999
}
