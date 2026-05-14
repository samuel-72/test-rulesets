output "repository_full_name" {
  description = "Full repository name."
  value       = github_repository.this.full_name
}

output "main_ruleset_ref" {
  description = "Ref protected by the main ruleset."
  value       = local.main_branch_ref
}

output "main_ruleset_id" {
  description = "GitHub ruleset ID for the main ruleset."
  value       = try(github_repository_ruleset.main[0].ruleset_id, null)
}

output "main_ruleset_url" {
  description = "GitHub web URL for the main ruleset."
  value       = try("https://github.com/${github_repository.this.full_name}/rules/${github_repository_ruleset.main[0].ruleset_id}", null)
}
