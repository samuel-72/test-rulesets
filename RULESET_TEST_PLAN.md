# Ruleset Test Plan

This plan validates the Terraform-managed repository ruleset:

- Repository: `samuel-72/test-rulesets`
- Ruleset: `test-rulesets-master-branch-protection`
- Target ref: `refs/heads/master`
- Enforcement: `active`

## Preconditions

- Terraform has been applied and the ruleset exists in GitHub.
- A `master` branch exists. The current repository default branch is `main`, so create `master` first or change the ruleset target before running these tests.
- The tester has a normal write-capable account and, for approval scenarios, access to a second account or collaborator.
- The required status check context is available as `policy-bot: master`.
- Local checkout is clean before each scenario.

## Setup

```sh
git checkout main
git pull
git checkout -B master origin/main
git push origin master
```

If creating `master` is blocked, create it before enabling the ruleset or temporarily set `master_ruleset_enforcement = "disabled"`, apply, create the branch, then set it back to `active` and apply again.

## Scenario 1: Ruleset Exists And Targets Master

Goal: Confirm the ruleset is visible and scoped correctly.

Steps:

1. Open `https://github.com/samuel-72/test-rulesets/rules/16419072`.
2. Confirm the ruleset name is `test-rulesets-master-branch-protection`.
3. Confirm enforcement is `Active`.
4. Confirm the target is branch `master`.

Expected result: The ruleset is visible in the UI and applies only to `refs/heads/master`.

## Scenario 2: Direct Push To Master Is Blocked By PR Requirement

Goal: Verify changes cannot be pushed directly to `master` when they bypass the pull request flow.

Steps:

1. Checkout `master`.
2. Commit a small change.
3. Push directly to `master`.

```sh
git checkout master
printf "\nDirect push test\n" >> direct-push-test.txt
git add direct-push-test.txt
git commit -m "Test direct push protection"
git push origin master
```

Expected result: The push is rejected because matching branches require changes to be made through a pull request.

Cleanup: Reset the local commit after the rejected push.

```sh
git reset --hard origin/master
```

## Scenario 3: Pull Request Without Approval Is Blocked

Goal: Verify at least one approval is required.

Steps:

1. Create a feature branch from `master`.
2. Commit and push a small change.
3. Open a pull request targeting `master`.
4. Do not approve the pull request.
5. Try to merge it.

Expected result: GitHub blocks the merge because 1 approving review is required.

## Scenario 4: Pull Request With Approval But Missing Status Check Is Blocked

Goal: Verify the required `policy-bot: master` status check is enforced.

Steps:

1. Use the pull request from Scenario 3 or open a new pull request targeting `master`.
2. Have another collaborator approve the pull request.
3. Ensure `policy-bot: master` is missing, pending, failing, or not successful.
4. Try to merge the pull request.

Expected result: GitHub blocks the merge because the required status check has not passed.

## Scenario 5: Pull Request With Approval And Passing Status Check Can Merge

Goal: Verify the happy path.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval from another collaborator.
3. Ensure `policy-bot: master` succeeds.
4. Merge the pull request.

Expected result: GitHub allows the merge.

## Scenario 6: Branch Does Not Need To Be Up To Date

Goal: Verify `strict_required_status_checks = false`.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval.
3. Make `policy-bot: master` pass.
4. Add another commit to `master` from a separate pull request.
5. Return to the first pull request without updating its branch.
6. Try to merge it.

Expected result: GitHub does not require the pull request branch to be updated with the latest `master` before merging, as long as the required status check is successful for the pull request head commit.

## Scenario 7: New Commits Do Not Dismiss Existing Approval

Goal: Verify `dismiss_stale_reviews_on_push = false`.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval.
3. Push another commit to the same pull request branch.
4. Check the review state.

Expected result: The existing approval remains valid and is not dismissed as stale.

## Scenario 8: Last Pusher Can Be Approved By Existing Review

Goal: Verify `require_last_push_approval = false`.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval.
3. Have the pull request author push another commit.
4. Ensure the required status check passes.
5. Try to merge.

Expected result: GitHub does not require a new approval from someone other than the most recent pusher.

## Scenario 9: Code Owner Review Is Not Required

Goal: Verify `require_code_owner_review = false`.

Steps:

1. Add or use a `CODEOWNERS` file that assigns ownership to a test path.
2. Open a pull request targeting `master` that changes a file matching that path.
3. Get 1 approval from a collaborator who is not the code owner.
4. Ensure `policy-bot: master` passes.
5. Try to merge.

Expected result: GitHub allows the merge without a code owner approval.

Cleanup: Remove the temporary `CODEOWNERS` entry if it was added only for this test.

## Scenario 10: Unresolved Conversations Do Not Block Merge

Goal: Verify `required_review_thread_resolution = false`.

Steps:

1. Open a pull request targeting `master`.
2. Ask a reviewer to leave an unresolved review comment.
3. Get 1 approval.
4. Ensure `policy-bot: master` passes.
5. Try to merge without resolving the conversation.

Expected result: GitHub allows the merge even with unresolved conversations.

## Scenario 11: Unsigned Commits Are Allowed

Goal: Verify signed commits are not required.

Steps:

1. Disable local commit signing or use an unsigned test commit.
2. Open a pull request targeting `master`.
3. Get 1 approval.
4. Ensure `policy-bot: master` passes.
5. Try to merge.

Expected result: GitHub allows the merge with unsigned commits.

## Scenario 12: Merge Commits Are Allowed

Goal: Verify linear history is not required.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval.
3. Ensure `policy-bot: master` passes.
4. Use the regular merge commit option, not squash or rebase.

Expected result: GitHub allows a merge commit.

## Scenario 13: Merge Queue Is Not Required

Goal: Verify pull requests do not need to enter a merge queue.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval.
3. Ensure `policy-bot: master` passes.
4. Merge directly from the pull request page.

Expected result: GitHub allows direct merge without merge queue.

## Scenario 14: Deployments Are Not Required

Goal: Verify deployment gates are not required.

Steps:

1. Open a pull request targeting `master`.
2. Get 1 approval.
3. Ensure `policy-bot: master` passes.
4. Do not create any deployment.
5. Try to merge.

Expected result: GitHub allows the merge without deployment success.

## Scenario 15: Force Push To Master Is Blocked

Goal: Verify `non_fast_forward = true`.

Steps:

1. Checkout `master`.
2. Reset local `master` behind the remote.
3. Try to force push.

```sh
git checkout master
git fetch origin
git reset --hard HEAD~1
git push --force origin master
```

Expected result: The force push is rejected.

Cleanup:

```sh
git fetch origin
git reset --hard origin/master
```

## Scenario 16: Deleting Master Is Blocked

Goal: Verify `deletion = true`.

Steps:

```sh
git push origin --delete master
```

Expected result: GitHub rejects deletion of `master`.

## Scenario 17: Other Branches Are Not Affected

Goal: Verify the ruleset only targets `master`.

Steps:

1. Create a non-master branch.
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

Expected result: Direct push and deletion succeed because the ruleset only targets `refs/heads/master`.

Cleanup:

```sh
git checkout master
git branch -D ruleset-unprotected-branch-test
```

## Scenario 18: Terraform Drift Check

Goal: Verify the UI ruleset still matches Terraform.

Steps:

```sh
terraform plan -var-file=terraform.tfvars.example
```

Expected result: Terraform reports no changes after the ruleset has been applied and no manual UI edits have been made.
