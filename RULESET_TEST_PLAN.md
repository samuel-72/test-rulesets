# Ruleset Test Plan

This plan validates the Terraform-managed repository ruleset:

- Repository: `samuel-72/test-rulesets`
- Ruleset: `test-rulesets-main-branch-protection`
- Target ref: `refs/heads/main`
- Enforcement: `active`

## Preconditions

- Terraform has been applied and the ruleset exists in GitHub.
- The `main` branch exists and is the repository default branch.
- The tester has a normal write-capable account and, for approval scenarios, access to a second account or collaborator.
- Local checkout is clean before each scenario.

## Setup

```sh
git fetch origin
git checkout main
git pull --ff-only origin main
```

## Scenario 1: Ruleset Exists And Targets Main

Goal: Confirm the ruleset is visible and scoped correctly.

Steps:

1. Open `https://github.com/samuel-72/test-rulesets/rules/16419072`.
2. Confirm the ruleset name is `test-rulesets-main-branch-protection`.
3. Confirm enforcement is `Active`.
4. Confirm the target is branch `main`.

Expected result: The ruleset is visible in the UI and applies only to `refs/heads/main`.

## Scenario 2: Direct Push To Main Is Blocked By PR Requirement

Goal: Verify changes cannot be pushed directly to `main` when they bypass the pull request flow.

Steps:

1. Checkout `main`.
2. Commit a small change.
3. Push directly to `main`.

```sh
git checkout main
printf "\nDirect push test\n" >> direct-push-test.txt
git add direct-push-test.txt
git commit -m "Test direct push protection"
git push origin main
```

Expected result: The push is rejected because matching branches require changes to be made through a pull request.

Cleanup: Reset the local commit after the rejected push.

```sh
git reset --hard origin/main
```

## Scenario 3: Pull Request Without Approval Is Blocked

Goal: Verify at least one approval is required.

Steps:

1. Create a feature branch from `main`.
2. Commit and push a small change.
3. Open a pull request targeting `main`.
4. Do not approve the pull request.
5. Try to merge it.

Expected result: GitHub blocks the merge because 1 approving review is required.

## Scenario 4: Status Checks Are Not Required

Goal: Verify the ruleset does not require a non-existent status check.

Steps:

1. Use the pull request from Scenario 3 or open a new pull request targeting `main`.
2. Have another collaborator approve the pull request.
3. Do not create or wait for any status check.
4. Confirm the merge box does not list required status checks.

Expected result: GitHub does not block the pull request for a missing status check.

## Scenario 5: Pull Request With Approval Can Merge

Goal: Verify the happy path.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval from another collaborator.
3. Merge the pull request.

Expected result: GitHub allows the merge.

## Scenario 6: Branch Does Not Need To Be Up To Date

Goal: Verify `strict_required_status_checks = false`.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval.
3. Add another commit to `main` from a separate pull request.
4. Return to the first pull request without updating its branch.
5. Try to merge it.

Expected result: GitHub does not require the pull request branch to be updated with the latest `main` before merging, assuming there is no merge conflict.

## Scenario 7: New Commits Do Not Dismiss Existing Approval

Goal: Verify `dismiss_stale_reviews_on_push = false`.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval.
3. Push another commit to the same pull request branch.
4. Check the review state.

Expected result: The existing approval remains valid and is not dismissed as stale.

## Scenario 8: Last Pusher Can Be Approved By Existing Review

Goal: Verify `require_last_push_approval = false`.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval.
3. Have the pull request author push another commit.
4. Try to merge.

Expected result: GitHub does not require a new approval from someone other than the most recent pusher.

## Scenario 9: Code Owner Review Is Not Required

Goal: Verify `require_code_owner_review = false`.

Steps:

1. Add or use a `CODEOWNERS` file that assigns ownership to a test path.
2. Open a pull request targeting `main` that changes a file matching that path.
3. Get 1 approval from a collaborator who is not the code owner.
4. Try to merge.

Expected result: GitHub allows the merge without a code owner approval.

Cleanup: Remove the temporary `CODEOWNERS` entry if it was added only for this test.

## Scenario 10: Unresolved Conversations Do Not Block Merge

Goal: Verify `required_review_thread_resolution = false`.

Steps:

1. Open a pull request targeting `main`.
2. Ask a reviewer to leave an unresolved review comment.
3. Get 1 approval.
4. Try to merge without resolving the conversation.

Expected result: GitHub allows the merge even with unresolved conversations.

## Scenario 11: Unsigned Commits Are Allowed

Goal: Verify signed commits are not required.

Steps:

1. Disable local commit signing or use an unsigned test commit.
2. Open a pull request targeting `main`.
3. Get 1 approval.
4. Try to merge.

Expected result: GitHub allows the merge with unsigned commits.

## Scenario 12: Merge Commits Are Allowed

Goal: Verify linear history is not required.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval.
3. Use the regular merge commit option, not squash or rebase.

Expected result: GitHub allows a merge commit.

## Scenario 13: Merge Queue Is Not Required

Goal: Verify pull requests do not need to enter a merge queue.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval.
3. Merge directly from the pull request page.

Expected result: GitHub allows direct merge without merge queue.

## Scenario 14: Deployments Are Not Required

Goal: Verify deployment gates are not required.

Steps:

1. Open a pull request targeting `main`.
2. Get 1 approval.
3. Do not create any deployment.
4. Try to merge.

Expected result: GitHub allows the merge without deployment success.

## Scenario 15: Force Push To Main Is Blocked

Goal: Verify `non_fast_forward = true`.

Steps:

1. Checkout `main`.
2. Reset local `main` behind the remote.
3. Try to force push.

```sh
git checkout main
git fetch origin
git reset --hard HEAD~1
git push --force origin main
```

Expected result: The force push is rejected.

Cleanup:

```sh
git fetch origin
git reset --hard origin/main
```

## Scenario 16: Deleting Main Is Blocked

Goal: Verify `deletion = true`.

Steps:

```sh
git push origin --delete main
```

Expected result: GitHub rejects deletion of `main`.

## Scenario 17: Other Branches Are Not Affected

Goal: Verify the ruleset only targets `main`.

Steps:

1. Create a non-main branch.
2. Push directly to that branch.
3. Delete that branch.

```sh
git checkout -B ruleset-unprotected-branch-test
printf "\nUnprotected branch test\n" >> unprotected-branch-test.txt
git add unprotected-branch-test.txt
git commit -m "Test unprotected branch behavior"
git push origin ruleset-unprotected-branch-test
git push origin --delete ruleset-unprotected-branch-test
```

Expected result: Direct push and deletion succeed because the ruleset only targets `refs/heads/main`.

Cleanup:

```sh
git checkout main
git branch -D ruleset-unprotected-branch-test
```

## Scenario 18: Terraform Drift Check

Goal: Verify the UI ruleset still matches Terraform.

Steps:

```sh
terraform plan -var-file=terraform.tfvars.example
```

Expected result: Terraform reports no changes after the ruleset has been applied and no manual UI edits have been made.
