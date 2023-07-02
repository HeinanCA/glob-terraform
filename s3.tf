module "s3_module" {
  source = "./modules/s3_module"
  # web_bucket
  aws_s3_bucket           = lower("${local.naming_prefix}-${random_integer.s3_seed_generator.result}")
  elb_service_account_arn = data.aws_elb_service_account.main.arn
  common_tags             = local.common_tags
}
# aws_s3_object
resource "aws_s3_object" "s3_index" {
  for_each = fileset("${path.module}", "website/**") # could use ** instead for a recursive search
  bucket   = module.s3_module.s3_bucket.bucket
  key      = each.value
  source   = "${path.module}/${each.value}"
}
