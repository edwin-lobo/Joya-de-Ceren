# infra/providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    # Use the merged local map for default tags
    tags = local.common_tags
  }
}

# Provider alias for creating ACM certificate in us-east-1 (required for CloudFront)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  default_tags {
    # Also use the merged local map here
    tags = local.common_tags
  }
}
