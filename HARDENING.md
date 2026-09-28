<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.10** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character commit SHAs. This exposes the action to supply-chain attacks if any of these upstream actions are compromised or their tags are moved. Failing references: `actions/checkout@v4`, `aws-actions/configure-aws-credentials@v4`, `hashicorp/setup-terraform@v3`.

Locations:

- `action.yaml:131`
- `action.yaml:136`
- `action.yaml:163`

### script-injection (severity: high)

Rule (a) violation: In the 'Print result' step, the expression `${{ steps.apply.outputs.public_url }}` is interpolated directly inside a `run:` shell command: `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY`. The `steps.*.outputs.*` context is a workflow-controllable value that is substituted into the shell command string by the Actions runner before the shell ever sees it. If the output contains shell metacharacters (e.g. `;`, `$(...)`, backticks), they will be interpreted by the shell. The value should be passed via an `env:` variable and double-quoted: `echo "$PUBLIC_URL" >> $GITHUB_STEP_SUMMARY`.

Locations:

- `action.yaml:196`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed three unpinned `uses:` references by replacing mutable version tags with full 40-character commit SHAs (actions/checkout@v4 → SHA 11d5960a..., aws-actions/configure-aws-credentials@v4 → SHA 7474bc46..., hashicorp/setup-terraform@v3 → SHA b9cd54a3...). Fixed script injection in the 'Print result' step by moving `${{ steps.apply.outputs.public_url }}` into an `env:` block as `PUBLIC_URL` and referencing it as `"$PUBLIC_URL"` in the shell command.

