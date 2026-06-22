<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.10** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml use mutable tag-based refs instead of pinned 40-character SHA digests, making the action vulnerable to supply-chain attacks if the referenced tags are moved or compromised:
- `uses: actions/checkout@v4`
- `uses: aws-actions/configure-aws-credentials@v4`
- `uses: hashicorp/setup-terraform@v3`
Each should be pinned to a full commit SHA (e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`).

Locations:

- `action.yaml:130`
- `action.yaml:135`
- `action.yaml:165`

### script-injection (severity: high)

Rule (a) violation: The 'Print result' step directly interpolates `${{ steps.apply.outputs.public_url }}` inside a `run:` shell command string:

  echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY

The `steps.*.outputs.*` context is substituted by the YAML template engine before the shell processes the command. If the Terraform output value contains shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.), they will be interpreted by bash, enabling command injection. The value should be passed via an `env:` variable and double-quoted: `echo "$PUBLIC_URL" >> $GITHUB_STEP_SUMMARY`.

Locations:

- `action.yaml:196`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed three unpinned `uses:` references by replacing mutable tags with full 40-character commit SHAs: actions/checkout@v4 → @34e114876b0b11c390a56381ad16ebd13914f8d5, aws-actions/configure-aws-credentials@v4 → @7474bc4690e29a8392af63c5b98e7449536d5c3a, hashicorp/setup-terraform@v3 → @b9cd54a3c349d3f38e8881555d616ced269862dd. Fixed script injection in the 'Print result' step by moving `${{ steps.apply.outputs.public_url }}` into an `env:` block as `PUBLIC_URL` and referencing it as `"$PUBLIC_URL"` in the shell command.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all unquoted shell variable expansions in scripts/generate_deploy.sh and scripts/check_bucket_name.sh:

1. generate_deploy.sh line 19: Quoted `$2` in `alpha_only $2` call inside `generate_var` function → `alpha_only "$2"`
2. generate_deploy.sh lines 25-26: Quoted `$GITHUB_REPOSITORY` in `echo $GITHUB_REPOSITORY | sed ...` → `echo "$GITHUB_REPOSITORY" | sed ...`
3. generate_deploy.sh lines 100-130: Quoted all 21 user-controlled variables passed to `generate_var` calls (e.g. `generate_var aws_tf_state_bucket $TF_STATE_BUCKET` → `generate_var aws_tf_state_bucket "$TF_STATE_BUCKET"`, and similarly for all other AWS_* variables)
4. generate_deploy.sh line 130: Quoted `$TF_STATE_BUCKET` and `$GITHUB_ACTION_PATH` in the `check_bucket_name.sh` invocation → `/bin/bash "$GITHUB_ACTION_PATH/scripts/check_bucket_name.sh" "$TF_STATE_BUCKET"`
5. check_bucket_name.sh: Quoted `$1` in the `checkBucket $1` call → `checkBucket "$1"`

These changes prevent attackers from injecting shell metacharacters (`;`, `|`, `$(...)`, etc.) through any of the user-controlled input variables.

