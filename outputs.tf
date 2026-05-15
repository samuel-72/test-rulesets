output "repository" {
  description = "Repository managed by this Terraform project."
  value       = module.test_rulesets.repository_full_name
}

output "main_ruleset_ref" {
  description = "Ref protected by the main repository ruleset."
  value       = module.test_rulesets.main_ruleset_ref
}

output "main_ruleset_id" {
  description = "GitHub repository ruleset ID for the main protection ruleset."
  value       = module.test_rulesets.main_ruleset_id
}

output "main_ruleset_url" {
  description = "GitHub web URL for the main protection ruleset."
  value       = module.test_rulesets.main_ruleset_url
}

output "feature_ruleset_refs" {
  description = "Refs protected by the feature branch ruleset."
  value       = module.test_rulesets.feature_ruleset_refs
}

output "feature_ruleset_id" {
  description = "GitHub repository ruleset ID for the feature branch ruleset."
  value       = module.test_rulesets.feature_ruleset_id
}

output "feature_ruleset_url" {
  description = "GitHub web URL for the feature branch ruleset."
  value       = module.test_rulesets.feature_ruleset_url
}
