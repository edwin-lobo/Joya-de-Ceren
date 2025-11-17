variable "punycode_domain_name" {
  description = "The Punycode version of your custom domain (e.g., xn--cern-sna.com for Cerén.com)"
  type        = string
  default     = "xn--cern-dpa.com"
}

variable "punycode_domain_zone_id" {
  description = "The Punycode version of your custom domain (e.g., xn--cern-sna.com for Cerén.com)"
  type        = string
  default     = "Z07728812PFXO0UGJ04RP"
}

variable "www_punycode_domain_name" {
  description = "The Punycode version of the www subdomain (e.g., www.xn--cern-sna.com)"
  type        = string
  default     = "www.xn--cern-dpa.com"
}

variable "s3_bucket_name_prefix" {
  description = "Prefix for the S3 bucket name to ensure uniqueness."
  type        = string
  default     = "dev-100-ceren" # Will append random suffix now
}

variable "whitelisted_ips" {
  description = "List of IPv4 or IPv6 CIDR ranges to allow access via WAF."
  type        = list(string)
  # default = ["YOUR_IPV4_HOME/32", "YOUR_IPV6_HOME/128", "YOUR_OFFICE_NETWORK/24"] # <-- !!! REPLACE WITH YOUR ACTUAL IPs/RANGES !!!
  # Example: ["192.0.2.44/32", "2001:db8::/64"]
  default = ["2600:4040:1060:f900:70d9:d812:fbf8:f343/128"] # Defaulting to empty list - PROVIDE YOUR IPs!
  validation {
    condition     = length(var.whitelisted_ips) > 0
    error_message = "Please provide at least one IP address/range in the whitelisted_ips variable."
  }
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default = {
    Project     = "CreativeMarketplace"
    Environment = "production" # Or staging, development
    ManagedBy   = "Terraform"
    # Repo tag removed from here
  }
}

# Other variables remain the same...
variable "aws_region" {
  description = "The primary AWS region for deploying resources (except ACM Cert)."
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "Your GitHub organization or username"
  type        = string
  # default = "your-github-username"
}

variable "github_repo" {
  description = "Your GitHub repository name"
  type        = string
  # default = "your-repo-name"
}
