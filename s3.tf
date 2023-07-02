# aws_s3_bucket
resource "aws_s3_bucket" "s3" {
  bucket        = local.s3_bucket_name
  force_destroy = true
}

# aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${data.aws_elb_service_account.main.arn}"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}/nginx-lb/*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}/nginx-lb/*",
        "Condition" : {
          "StringEquals" : {
            "s3:x-amz-acl" : "bucket-owner-full-control"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "arn:aws:s3:::${local.s3_bucket_name}"
      }
    ]
  })
}

# aws_s3_object
resource "aws_s3_object" "s3_index" {
  for_each = fileset("${path.module}", "website/**") # could use ** instead for a recursive search
  bucket   = aws_s3_bucket.s3.bucket
  key      = each.value
  source   = "${path.module}/${each.value}"
}
