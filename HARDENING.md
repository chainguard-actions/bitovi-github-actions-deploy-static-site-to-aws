<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.10** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml use mutable version tags instead of pinned 40-character SHA commit hashes, making the action vulnerable to supply-chain attacks if the referenced tags are moved or overwritten:
- `uses: actions/checkout@v4` (line ~155)
- `uses: aws-actions/configure-aws-credentials@v4` (line ~159)
- `uses: hashicorp/setup-terraform@v3` (line ~196)
All three should be pinned to their full SHA digest, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `action.yaml:155`
- `action.yaml:159`
- `action.yaml:196`

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is directly interpolated inside a `run:` shell command string. In the 'Print result' step, the line `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY` embeds the `steps.apply.outputs.public_url` context value directly into the shell command before the shell ever sees it. Since `steps.*.outputs.*` is a workflow-controllable context (the output is derived from `terraform output` which can be influenced by infrastructure state or attacker-controlled inputs), this constitutes a script-injection risk — an attacker could craft a value containing shell metacharacters. The value should be passed via an `env:` variable and double-quoted: `echo "$PUBLIC_URL" >> $GITHUB_STEP_SUMMARY`.

Locations:

- `action.yaml:222`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed three unpinned action references by resolving their full SHA commit hashes via lookup_action_sha: actions/checkout@v4 → SHA 11d5960a..., aws-actions/configure-aws-credentials@v4 → SHA 7474bc46..., hashicorp/setup-terraform@v3 → SHA b9cd54a3.... Fixed script injection in the 'Print result' step by moving `${{ steps.apply.outputs.public_url }}` into an env var `PUBLIC_URL` and referencing it as `"$PUBLIC_URL"` in the shell command.

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 19 unquoted variable expansions in `scripts/generate_deploy.sh`. Each `generate_var` function call that passed an unquoted `$VAR` as the second argument has been updated to use `"$VAR"` (double-quoted). This prevents word splitting and glob expansion of attacker-controlled input values (sourced from action inputs via the env: block in action.yaml), eliminating the shell command injection risk. The affected variables were: TF_STATE_BUCKET, AWS_ADDITIONAL_TAGS, AWS_DEFAULT_REGION, AWS_SITE_BUCKET_NAME, AWS_SITE_CDN_ENABLED, AWS_SITE_CDN_ALIASES, AWS_SITE_CDN_CUSTOM_ERROR_CODES, AWS_SITE_CDN_RESPONSE_HEADERS_POLICY_ID, AWS_SITE_CDN_MIN_TTL, AWS_SITE_CDN_DEFAULT_TTL, AWS_SITE_CDN_MAX_TTL, AWS_SITE_ROOT_OBJECT, AWS_SITE_ERROR_DOCUMENT, AWS_R53_DOMAIN_NAME, AWS_R53_ROOT_DOMAIN_DEPLOY, AWS_SITE_CDN_ENABLED (for aws_r53_enable_cert), AWS_R53_CERT_ARN, AWS_R53_CREATE_ROOT_CERT, and AWS_R53_CREATE_SUB_CERT.

