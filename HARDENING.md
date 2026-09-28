<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.9** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character commit SHAs. This exposes the action to supply-chain attacks if the upstream tag is moved or the repository is compromised. Failing references: `actions/checkout@v4`, `aws-actions/configure-aws-credentials@v4`, `hashicorp/setup-terraform@v3`.

Locations:

- `action.yaml:130`
- `action.yaml:135`
- `action.yaml:193`

### script-injection (severity: high)

Sub-rule (a): A `${{ ... }}` expression is interpolated directly inside a `run:` shell command string. In the "Print result" step, the line `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY` injects the `steps.apply.outputs.public_url` value through YAML template substitution before the shell ever sees it. If the Terraform output contains shell metacharacters, this can lead to command injection. The value should be passed via an `env:` variable and then referenced as a quoted `"$VAR"` in the shell script.

Locations:

- `action.yaml:248`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed three unpinned action references by resolving them to full 40-character commit SHAs: actions/checkout@v4 → @11d5960a326750d5838078e36cf38b85af677262, aws-actions/configure-aws-credentials@v4 → @7474bc4690e29a8392af63c5b98e7449536d5c3a, hashicorp/setup-terraform@v3 → @b9cd54a3c349d3f38e8881555d616ced269862dd. Fixed script injection in the 'Print result' step by moving the ${{ steps.apply.outputs.public_url }} expression into an env: block as PUBLIC_URL and referencing it as "$PUBLIC_URL" in the shell script.

