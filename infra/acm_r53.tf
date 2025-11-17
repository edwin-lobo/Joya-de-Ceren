# Example: infra/route53_zone.tf (or add to acm_route53.tf)
# NOTE: Only use this if you want Terraform to CREATE the zone.
# Remove the corresponding 'data' block from data.tf if you use this.

resource "aws_route53_zone" "primary" {
  name = "${var.punycode_domain_name}." # Ensure trailing dot if using resource block 'name' directly

  tags = {
    Name = "${var.punycode_domain_name}-zone"
  }
}

# Output the name servers so you can update your registrar
output "route53_zone_name_servers" {
  description = "Name servers for the Route 53 hosted zone. Update these at your domain registrar."
  value       = aws_route53_zone.primary.name_servers
}
# --- ACM Certificate for Custom Domain (in us-east-1) ---
resource "aws_acm_certificate" "cert" {
  provider = aws.us_east_1 # Use the us-east-1 provider alias

  domain_name               = var.punycode_domain_name
  subject_alternative_names = [var.www_punycode_domain_name]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true # Helps avoid downtime during certificate renewals/updates
  }
}

# --- Route 53 Records for ACM Validation ---
resource "aws_route53_record" "cert_validation" {
  # Creates the CNAME records needed to prove domain ownership to ACM
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.primary.zone_id # Use the Zone ID found in data.tf
    }
  }

  allow_overwrite = true # Useful if validation records already exist (e.g., from previous runs)
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60 # Short TTL for validation records
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# --- Wait for ACM Certificate Validation ---
resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us_east_1 # Use the us-east-1 provider alias

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  # This resource implicitly depends on the Route 53 records being created
  # and waits until ACM confirms validation before proceeding.
}


# --- Route 53 ALIAS Records pointing to CloudFront ---
resource "aws_route53_record" "apex_domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.punycode_domain_name
  type    = "A" # Use A record for Alias to CloudFront

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name    # Dynamic ref
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id # Dynamic ref
    evaluate_target_health = false                                                      # Standard for CloudFront alias
  }
}

resource "aws_route53_record" "www_domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.www_punycode_domain_name
  type    = "A" # Use A record for Alias to CloudFront

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name    # Dynamic ref
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id # Dynamic ref
    evaluate_target_health = false
  }
}
