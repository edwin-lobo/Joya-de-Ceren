data "aws_iam_policy_document" "allow_cloudfront_oac" {
  # Policy granting CloudFront GetObject access via OAC
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"] # Access objects within the bucket
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      # Reference the CloudFront ARN, ensuring dependency
      values = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront_oac_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudfront_oac.json

  # Explicit dependency helpful here since CloudFront ID is used in the policy doc
  depends_on = [aws_cloudfront_distribution.s3_distribution]
}
