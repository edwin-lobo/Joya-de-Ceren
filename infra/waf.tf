resource "aws_wafv2_ip_set" "whitelist" {
  name        = "${var.punycode_domain_name}-whitelist-ipset"
  description = "IP addresses allowed to access ${var.punycode_domain_name}"
  scope       = "CLOUDFRONT" # Important: Scope must be CLOUDFRONT for CloudFront distributions

  # --- Updated for IPv6/Both ---
  ip_address_version = "IPV6" # Set to "IPV4", "IPV6", or "BOTH"
  addresses          = var.whitelisted_ips
}

resource "aws_wafv2_web_acl" "acl" {
  name        = "${var.punycode_domain_name}-web-acl"
  description = "Web ACL for ${var.punycode_domain_name} to whitelist IPs"
  scope       = "CLOUDFRONT" # Important: Scope must be CLOUDFRONT

  default_action {
    block {} # Block requests by default
  }

  # Rule to allow requests matching the IP set
  rule {
    name     = "AllowWhitelistedIPs"
    priority = 1 # Lower number = higher priority

    action {
      allow {} # Allow requests that match this rule
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelist.arn # Reference the IP set created above
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowWhitelistedIPsMetric"
      sampled_requests_enabled   = true # Set to false to reduce cost if sampling not needed
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.punycode_domain_name}WebACLMetric"
    sampled_requests_enabled   = true # Set to false to reduce cost if sampling not needed
  }
}
