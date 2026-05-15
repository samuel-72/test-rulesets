variable "name" {
  description = "Repository name."
  type        = string
}

variable "description" {
  description = "Repository description."
  type        = string
  default     = null
}

variable "visibility" {
  description = "Repository visibility."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be public, private, or internal."
  }
}

variable "has_issues" {
  description = "Enable GitHub Issues."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Enable GitHub Projects."
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Enable the GitHub Wiki."
  type        = bool
  default     = true
}

variable "enable_ruleset_main_protection" {
  description = "Set to true to create a github_repository_ruleset that mirrors the classic main branch protection."
  type        = bool
  default     = false
}

variable "main_ruleset_enforcement" {
  description = "Enforcement mode for the main ruleset. GitHub only supports evaluate on Enterprise plans; use active to enforce or disabled to turn it off."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "evaluate", "disabled"], var.main_ruleset_enforcement)
    error_message = "main_ruleset_enforcement must be active, evaluate, or disabled."
  }
}

variable "enable_ruleset_feature_protection" {
  description = "Set to true to create a github_repository_ruleset for branches whose names start with feature."
  type        = bool
  default     = false
}

variable "feature_ruleset_enforcement" {
  description = "Enforcement mode for the feature branch ruleset. GitHub only supports evaluate on Enterprise plans; use active to enforce or disabled to turn it off."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "evaluate", "disabled"], var.feature_ruleset_enforcement)
    error_message = "feature_ruleset_enforcement must be active, evaluate, or disabled."
  }
}

variable "feature_branch_include_patterns" {
  description = "GitHub ref patterns for feature branches protected by the feature ruleset."
  type        = list(string)
  default     = ["refs/heads/feature*"]

  validation {
    condition = alltrue([
      for pattern in var.feature_branch_include_patterns :
      startswith(pattern, "refs/heads/")
    ])
    error_message = "feature_branch_include_patterns entries must be full refs like refs/heads/feature*."
  }
}

variable "feature_allow_force_pushes" {
  description = "When true, do not add the non-fast-forward rule for feature branches so force pushes are allowed."
  type        = bool
  default     = true
}

variable "dismiss_stale_reviews" {
  description = "Dismiss approving pull request reviews when new commits are pushed."
  type        = bool
  default     = false
}

variable "require_code_owner_review" {
  description = "Require review from Code Owners before merging."
  type        = bool
  default     = false
}

variable "require_last_push_approval" {
  description = "Require the most recent reviewable push to be approved by someone other than the person who pushed it."
  type        = bool
  default     = false
}

variable "required_approving_review_count" {
  description = "Number of required approving reviews before merging."
  type        = number
  default     = 1
}

variable "required_review_thread_resolution" {
  description = "Require all review threads to be resolved before merging."
  type        = bool
  default     = false
}

variable "required_status_checks" {
  description = "Status check contexts required before merging to main."
  type        = set(string)
  default     = []
}

variable "strict_required_status_checks" {
  description = "Require pull request branches to be up to date before merging."
  type        = bool
  default     = false
}
