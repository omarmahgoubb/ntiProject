resource "aws_s3_bucket" "elb_logs_bucket" {
  bucket = "project-elb-logs-${random_id.bucket_suffix.hex}"
  acl    = "private"

  tags = {
    Name = "project-elb-logs"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_policy" "elb_logging_policy" {
  bucket = aws_s3_bucket.elb_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowELBWrite",
        Effect    = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.elb_logs_bucket.arn}/*"
      }
    ]
  })
}

