# --- IAM Role for GitHub Actions (OIDC) ---
data "aws_iam_policy_document" "github_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type = "Federated"
      # Reference the OIDC provider ARN - uses coalesce for robustness if provider exists or not
      identifiers = [coalesce(try(aws_iam_openid_connect_provider.github[0].arn, null), data.aws_iam_openid_connect_provider.github_check.arn)]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # IMPORTANT: Scoped to your specific repo and main branch
      values = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"]
    }
    # Optional: Add condition for workflow name for extra security
    # condition {
    #   test     = "StringEquals"
    #   variable = "token.actions.githubusercontent.com:workflow"
    #   values   = ["deploy-frontend.yml"] # Match your workflow file name
    # }
  }
}


resource "aws_iam_openid_connect_provider" "github" {
  # Create only if the data source lookup failed (implies provider doesn't exist)
  # Note: First run might error if provider doesn't exist and data source fails hard.
  # Re-running after failure or manual creation resolves this.
  # Robustness check: try() attempts to access the data source attribute, returns null on error
  count = try(data.aws_iam_openid_connect_provider.github_check.url, "") == "" ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # Check AWS docs for current thumbprint
}

resource "aws_iam_role" "github_actions_deploy_role" {
  name                 = "GitHubActionsDeployRole-${var.github_repo}-${random_string.bucket_suffix.result}" # Add randomness
  assume_role_policy   = data.aws_iam_policy_document.github_oidc_assume_role_policy.json
  description          = "IAM Role assumed by GitHub Actions for repo ${var.github_org}/${var.github_repo}"
  max_session_duration = 3600 # Optional: Set max session duration (default 1hr)
}

# Policy allowing S3 sync and CloudFront invalidation
data "aws_iam_policy_document" "deploy_policy_document" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      aws_s3_bucket.frontend_bucket.arn,
      "${aws_s3_bucket.frontend_bucket.arn}/*"
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      aws_cloudfront_distribution.s3_distribution.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "deploy_policy" {
  name        = "GitHubActionsDeployPolicy-${var.github_repo}-${random_string.bucket_suffix.result}" # Add randomness
  description = "Policy for GitHub Actions to deploy frontend for ${var.github_org}/${var.github_repo}"
  policy      = data.aws_iam_policy_document.deploy_policy_document.json
}

resource "aws_iam_role_policy_attachment" "deploy_policy_attach" {
  role       = aws_iam_role.github_actions_deploy_role.name
  policy_arn = aws_iam_policy.deploy_policy.arn
}
