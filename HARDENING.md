<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.9** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character SHA commit hashes, making the action vulnerable to supply-chain attacks if the upstream tag is moved:
- `actions/checkout@v4`
- `aws-actions/configure-aws-credentials@v4`
- `hashicorp/setup-terraform@v3`

Locations:

- `action.yaml:130`
- `action.yaml:135`
- `action.yaml:185`

### script-injection (severity: high)

Sub-rule (a): A `${{ ... }}` expression is directly interpolated inside a `run:` shell command string in the 'Print result' step. The offending line is:
  `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY`
The `steps.*.outputs.*` context is listed as a workflow-controllable value that must never appear directly inside a `run:` block. If the output contains shell metacharacters, they will be interpreted by the shell before the echo command executes.

Locations:

- `action.yaml:213`

### github-env-injection (severity: high)

The 'Terraform Apply' step writes terraform output directly to `$GITHUB_OUTPUT` without sanitization:
  `terraform -chdir=$GITHUB_ACTION_PATH/terraform_code output | grep public_url | sed -e 's/ *= */=/g' -e 's/"//g' >> $GITHUB_OUTPUT`
The `public_url` terraform output value is derived from user-controlled inputs (e.g. `aws_r53_domain_name`, `aws_r53_sub_domain_name`, `aws_site_cdn_aliases`) that flow through the terraform configuration. Writing this value to `$GITHUB_OUTPUT` without first applying `printf '%s' ... | tr -d '\n\r'` allows a newline-injection attack that could poison subsequent steps' environment variables or outputs.

Locations:

- `action.yaml:200`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed all three findings in action.yaml:
1. unpinned-uses: Pinned actions/checkout@v4 to SHA 34e114876b0b11c390a56381ad16ebd13914f8d5, aws-actions/configure-aws-credentials@v4 to SHA 7474bc4690e29a8392af63c5b98e7449536d5c3a, and hashicorp/setup-terraform@v3 to SHA b9cd54a3c349d3f38e8881555d616ced269862dd. Original version tags preserved as comments.
2. script-injection: Moved ${{ steps.apply.outputs.public_url }} out of the 'Print result' run: block into an env: block as PUBLIC_URL, then referenced it as $PUBLIC_URL in the shell script.
3. github-env-injection: In the 'Terraform Apply' step, the terraform output is now captured into a variable (raw_output), sanitized with printf '%s' "$raw_output" | tr -d '\n\r' to strip newlines, and then written to $GITHUB_OUTPUT safely.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection vulnerabilities in scripts/generate_deploy.sh and scripts/check_bucket_name.sh:

1. scripts/generate_deploy.sh (lines 37-57): All 21 calls to `generate_var` now pass user-controlled environment variables with double quotes (e.g., `generate_var aws_tf_state_bucket "$TF_STATE_BUCKET"` instead of `generate_var aws_tf_state_bucket $TF_STATE_BUCKET`). This prevents shell metacharacters in input values from being interpreted by bash before the function receives them.

2. scripts/generate_deploy.sh (check_bucket_name.sh invocation): Changed `/bin/bash $GITHUB_ACTION_PATH/scripts/check_bucket_name.sh $TF_STATE_BUCKET` to `/bin/bash "$GITHUB_ACTION_PATH/scripts/check_bucket_name.sh" "$TF_STATE_BUCKET"` — both the script path and the bucket name argument are now properly quoted.

3. scripts/generate_deploy.sh (generate_var function body): Fixed the internal `alpha_only $2` call to `alpha_only "$2"` to prevent word splitting inside the function.

4. scripts/check_bucket_name.sh: Fixed the unquoted `checkBucket $1` call to `checkBucket "$1"` to prevent word splitting when the function is invoked.

