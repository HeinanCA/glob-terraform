locals {
  common_tags = {
    Company     = var.Company
    Project     = "${var.Company}-NewCI/CD"
    BillingCode = var.BillingCode
  }
}