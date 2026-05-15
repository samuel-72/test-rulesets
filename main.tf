module "test_rulesets" {
  source = "./modules/repo"

  name        = var.repository_name
  description = var.repository_description
  visibility  = var.repository_visibility

  enable_ruleset_main_protection = var.enable_ruleset_main_protection
  main_ruleset_enforcement       = var.main_ruleset_enforcement

  enable_ruleset_feature_protection = var.enable_ruleset_feature_protection
  feature_ruleset_enforcement       = var.feature_ruleset_enforcement
  feature_branch_include_patterns   = var.feature_branch_include_patterns
  feature_allow_force_pushes        = var.feature_allow_force_pushes

  dismiss_stale_reviews             = var.dismiss_stale_reviews
  require_code_owner_review         = var.require_code_owner_review
  require_last_push_approval        = var.require_last_push_approval
  required_approving_review_count   = var.required_approving_review_count
  required_review_thread_resolution = var.required_review_thread_resolution
  required_status_checks            = var.required_status_checks
  strict_required_status_checks     = var.strict_required_status_checks
}
