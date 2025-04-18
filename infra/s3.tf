# Use random suffix for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.s3_bucket_name_prefix}-${random_string.bucket_suffix.result}"
  # bucket_prefix = var.s3_bucket_name_prefix # Alternative using prefix

  # Explicitly setting ACL to private (recommended over default)
  # acl = "private"
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket_public_access" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
