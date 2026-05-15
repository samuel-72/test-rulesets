locals {
  main_branch_ref = "refs/heads/main"
}

resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  has_issues   = var.has_issues
  has_projects = var.has_projects
  has_wiki     = var.has_wiki

  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_ruleset" "main" {
  count = var.enable_ruleset_main_protection ? 1 : 0

  name        = "${var.name}-main-branch-protection"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = var.main_ruleset_enforcement

  conditions {
    ref_name {
      include = [local.main_branch_ref]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      dismiss_stale_reviews_on_push     = var.dismiss_stale_reviews
      require_code_owner_review         = var.require_code_owner_review
      require_last_push_approval        = var.require_last_push_approval
      required_approving_review_count   = var.required_approving_review_count
      required_review_thread_resolution = var.required_review_thread_resolution
    }

    dynamic "required_status_checks" {
      for_each = length(var.required_status_checks) != 0 ? [1] : []

      content {
        dynamic "required_check" {
          for_each = var.required_status_checks

          content {
            context = required_check.key
          }
        }

        strict_required_status_checks_policy = var.strict_required_status_checks
      }
    }
  }

  depends_on = [
    github_repository.this,
  ]
}

resource "github_repository_ruleset" "feature" {
  count = var.enable_ruleset_feature_protection ? 1 : 0

  name        = "${var.name}-feature-branch-protection"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = var.feature_ruleset_enforcement

  conditions {
    ref_name {
      include = var.feature_branch_include_patterns
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = !var.feature_allow_force_pushes
  }

  depends_on = [
    github_repository.this,
  ]
}
