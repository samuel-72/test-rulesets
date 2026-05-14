output "repository_full_name" {
  description = "Full repository name."
  value       = github_repository.this.full_name
}

output "master_ruleset_ref" {
  description = "Ref protected by the master ruleset."
  value       = local.master_branch_ref
}

output "master_ruleset_id" {
  description = "GitHub ruleset ID for the master ruleset."
  value       = try(github_repository_ruleset.master[0].ruleset_id, null)
}

output "master_ruleset_url" {
  description = "GitHub web URL for the master ruleset."
  value       = try("https://github.com/${github_repository.this.full_name}/rules/${github_repository_ruleset.master[0].ruleset_id}", null)
}
