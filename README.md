# test-rulesets
A repo to test rulesets

## GitHub Ruleset Terraform

Terraform configuration for managing the branch protection behavior of `samuel-72/test-rulesets` with a repository ruleset.

### What This Applies

This configuration mirrors the module-style PR in the screenshot: the root config calls `modules/repo`, and that module manages the repository plus repository rulesets for `refs/heads/main` and branches that match `refs/heads/feature*`.

The ruleset mirrors the screenshot as closely as GitHub rulesets allow:

- Require pull requests before merging.
- Require 1 approving review.
- Do not require status checks, because this repository does not currently publish a stable required check context.
- Do not require stale review dismissal, code owner review, last-push approval, conversation resolution, signed commits, linear history, merge queue, or deployments.
- Do not allow branch deletion.
- Do not allow force pushes.
- Use `active` enforcement because GitHub only supports `evaluate` mode on Enterprise plans.

The feature branch ruleset applies to branch refs matching `refs/heads/feature*`. It blocks deletion but intentionally allows non-fast-forward updates so developers can rebase and push with `git push --force-with-lease`. GitHub cannot enforce "with lease" server-side; it can only allow or deny force pushes.

The old branch protection UI has a "Restrict who can push to matching branches" allow-list that is not a perfect one-to-one match in repository rulesets. The screenshot's ruleset-style PR does not add an update restriction or bypass actors, so this Terraform follows that pattern to avoid turning normal protected-branch merges into bypass-only operations.

### Usage

Create a token with permission to administer the repository, then run:

```sh
export GITHUB_TOKEN="..."
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

The repository default branch is `main`, so the ruleset targets `refs/heads/main`.
