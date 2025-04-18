resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "OAC-${aws_s3_bucket.frontend_bucket.id}" # Use bucket ID for unique name
  description                       = "OAC for ${aws_s3_bucket.frontend_bucket.id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
    origin_id                = "S3-${aws_s3_bucket.frontend_bucket.id}" # Unique Origin ID
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Frontend distribution for ${var.punycode_domain_name}"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # Use PriceClass_100 (US/EU) for cost savings if appropriate

  # Aliases for the custom domain (use Punycode)
  aliases = [var.punycode_domain_name, var.www_punycode_domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend_bucket.id}" # Match origin_id above

    # Using Cache Policy and Origin Request Policy for better management
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-CORS-S3Origin

    # The Managed-CORS-S3Origin policy handles required headers.
    # If not using that policy, configure forwarded_values like below:
    # forwarded_values {
    #   query_string = false
    #   headers      = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"] # For CORS if needed by S3
    #   cookies {
    #     forward = "none"
    #   }
    # }

    viewer_protocol_policy = "redirect-to-https"
    # TTLs are now managed by the Cache Policy above, but can be overridden:
    # min_ttl                = 0
    # default_ttl            = 3600
    # max_ttl                = 86400
    compress = true # Enable compression
  }

  # Configure custom error responses for SPA routing
  custom_error_response {
    error_code            = 403 # Required because WAF blocks with 403 by default
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10 # Short TTL for error page caching
  }
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # We are using WAF for IP restrictions
    }
  }

  # Associate the ACM Certificate (must be validated)
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn # Reference the validated cert ARN from acm_route53.tf
    ssl_support_method       = "sni-only"                                          # Standard setting
    minimum_protocol_version = "TLSv1.2_2021"                                      # Use a modern TLS version
  }

  # Associate the WAF Web ACL (from waf.tf)
  web_acl_id = aws_wafv2_web_acl.acl.arn
}
