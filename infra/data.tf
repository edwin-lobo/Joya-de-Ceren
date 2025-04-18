data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Assumes Route 53 zone is managed in AWS and exists
data "aws_route53_zone" "primary" {
  name         = "${var.punycode_domain_name}." # Note the trailing dot
  private_zone = false
}

# Check if GitHub OIDC Provider exists
data "aws_iam_openid_connect_provider" "github_check" {
  # This data source will error if the provider doesn't exist.
  # The iam.tf file handles this potential error using count for conditional creation.
  # Consider managing the OIDC provider outside this project if shared.
  url = "https://token.actions.githubusercontent.com"
}
