# infra/locals.tf

locals {
  # Construct the dynamic Repo tag using the input variables
  repo_tag = "github.com/${var.github_org}/${var.github_repo}"

  # Merge the basic default tags from the variable with the dynamic Repo tag
  common_tags = merge(var.tags, {
    Repo = local.repo_tag
  })
}
