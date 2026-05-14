output "repository" {
  description = "Repository managed by this Terraform project."
  value       = module.test_rulesets.repository_full_name
}

output "master_ruleset_ref" {
  description = "Ref protected by the master repository ruleset."
  value       = module.test_rulesets.master_ruleset_ref
}

output "master_ruleset_id" {
  description = "GitHub repository ruleset ID for the master protection ruleset."
  value       = module.test_rulesets.master_ruleset_id
}

output "master_ruleset_url" {
  description = "GitHub web URL for the master protection ruleset."
  value       = module.test_rulesets.master_ruleset_url
}
