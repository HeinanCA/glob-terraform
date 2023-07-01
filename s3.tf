# aws_s3_bucket
resource "aws_s3_bucket" "s3" {
  bucket = local.s3_bucket_name
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
  bucket = aws_s3_bucket.s3.bucket
  key    = "index.html"
  source = "website/index.html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("website/index.html")
}

resource "aws_s3_object" "s3_logo" {
  bucket = aws_s3_bucket.s3.bucket
  key    = "Globo_logo_Vert.png"
  source = "website/Globo_logo_Vert.png"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("website/Globo_logo_Vert.png")
}