# aws_s3_bucket
resource "aws_s3_bucket" "s3" {
  bucket        = var.aws_s3_bucket
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
          "AWS" : "${var.elb_service_account_arn}"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${var.aws_s3_bucket}/nginx-lb/*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${var.aws_s3_bucket}/nginx-lb/*",
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
        "Resource" : "arn:aws:s3:::${var.aws_s3_bucket}"
      }
    ]
  })
}

# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "${var.aws_s3_bucket}-allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.common_tags
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${var.aws_s3_bucket}-nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = var.common_tags
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "${var.aws_s3_bucket}-allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.aws_s3_bucket}",
                "arn:aws:s3:::${var.aws_s3_bucket}/*"
            ]
    }
  ]
}
EOF

}