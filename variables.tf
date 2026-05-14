variable "github_owner" {
  description = "GitHub user or organization that owns the repository."
  type        = string
  default     = "samuel-72"
}

variable "repository_name" {
  description = "Name of the repository to manage."
  type        = string
  default     = "test-rulesets"
}

variable "repository_description" {
  description = "Repository description."
  type        = string
  default     = "A repo to test rulesets"
}

variable "repository_visibility" {
  description = "Repository visibility."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private", "internal"], var.repository_visibility)
    error_message = "repository_visibility must be public, private, or internal."
  }
}

variable "enable_ruleset_master_protection" {
  description = "Set to true to create a github_repository_ruleset that mirrors the classic master branch protection."
  type        = bool
  default     = true
}

variable "master_ruleset_enforcement" {
  description = "Enforcement mode for the master ruleset. GitHub only supports evaluate on Enterprise plans; use active to enforce or disabled to turn it off."
  type        = string
  default     = "active"

  validation {
    condition     = contains(["active", "evaluate", "disabled"], var.master_ruleset_enforcement)
    error_message = "master_ruleset_enforcement must be active, evaluate, or disabled."
  }
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

  validation {
    condition     = var.required_approving_review_count >= 0
    error_message = "required_approving_review_count must be zero or greater."
  }
}

variable "required_review_thread_resolution" {
  description = "Require all review threads to be resolved before merging."
  type        = bool
  default     = false
}

variable "required_status_checks" {
  description = "Status check contexts required before merging to master."
  type        = set(string)
  default     = ["policy-bot: master"]
}

variable "strict_required_status_checks" {
  description = "Require pull request branches to be up to date before merging."
  type        = bool
  default     = false
}
