<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.9** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if those tags are moved:
- `uses: actions/checkout@v4` (line ~157)
- `uses: aws-actions/configure-aws-credentials@v4` (line ~161)
- `uses: hashicorp/setup-terraform@v3` (line ~199)
Each should be replaced with a full SHA digest, e.g. `actions/checkout@<40-hex-sha> # v4`.

Locations:

- `action.yaml:157`
- `action.yaml:161`
- `action.yaml:199`

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is interpolated directly inside a `run:` shell command in the 'Print result' step. The offending line is:
  `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY`
The `steps.*.outputs.*` context is workflow-controllable and flows through YAML template substitution before the shell sees it. If the `public_url` output contains shell metacharacters (e.g. injected via a crafted AWS resource name), they will be interpreted by the shell. The value must be moved to an `env:` variable and the env var must be double-quoted in the shell command.

Locations:

- `action.yaml:243`

### github-env-injection (severity: high)

The 'Terraform Apply' step writes terraform output directly to `$GITHUB_OUTPUT` without the required newline-stripping sanitization (`printf '%s' ... | tr -d '\n\r'`). The offending line is:
  `terraform -chdir=$GITHUB_ACTION_PATH/terraform_code output | grep public_url | sed -e 's/ *= */=/g' -e 's/"//g' >> $GITHUB_OUTPUT`
The `public_url` value is derived from AWS resource names that are themselves built from user-controlled inputs such as `inputs.aws_resource_identifier`, `inputs.aws_r53_domain_name`, `inputs.aws_r53_sub_domain_name`, and `GITHUB_HEAD_REF`. An attacker who can influence these inputs could inject newlines into the terraform output, causing arbitrary key=value pairs to be written into `$GITHUB_OUTPUT` and potentially poisoning subsequent steps.

Locations:

- `action.yaml:228`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed all three findings in action.yaml:
1. unpinned-uses: Pinned actions/checkout@v4 to SHA 11d5960a326750d5838078e36cf38b85af677262, aws-actions/configure-aws-credentials@v4 to SHA 7474bc4690e29a8392af63c5b98e7449536d5c3a, and hashicorp/setup-terraform@v3 to SHA b9cd54a3c349d3f38e8881555d616ced269862dd. Original tags preserved as comments.
2. script-injection: Moved `${{ steps.apply.outputs.public_url }}` in the 'Print result' step to an `env:` block as `PUBLIC_URL`, and updated the shell command to use `"$PUBLIC_URL"` (double-quoted).
3. github-env-injection: The Terraform Apply step now captures terraform output into `raw_output`, sanitizes it with `printf '%s' "$raw_output" | tr -d '\n\r'` into `safe_output`, then writes `safe_output` to `$GITHUB_OUTPUT`, preventing newline injection attacks.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 17 unquoted variable expansions in hardened/action/scripts/generate_deploy.sh. Each call to generate_var that passed an unquoted variable (e.g., `generate_var aws_additional_tags $AWS_ADDITIONAL_TAGS`) was updated to double-quote the variable argument (e.g., `generate_var aws_additional_tags "$AWS_ADDITIONAL_TAGS"`). This prevents word-splitting and glob expansion on attacker-controlled input values, eliminating the shell injection risk.

