resource "aws_s3_bucket" "alb_logs" {
  bucket        = var.alb_logs_bucket_name
  force_destroy = true
  tags = { Project = var.project_name }
}
resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule { object_ownership = "BucketOwnerPreferred" }
}
resource "aws_s3_bucket_acl" "alb_logs" {
  depends_on = [aws_s3_bucket_ownership_controls.alb_logs]
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "private"
}
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AWSLogDeliveryWrite",
      Effect    = "Allow",
      Principal = { Service = "logdelivery.elasticloadbalancing.amazonaws.com" },
      Action    = ["s3:PutObject","s3:PutObjectAcl"],
      Resource  = "${aws_s3_bucket.alb_logs.arn}/*",
      Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
    }]
  })
}
output "alb_logs_bucket"  { value = aws_s3_bucket.alb_logs.bucket }
