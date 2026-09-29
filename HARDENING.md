<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.9** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character commit SHAs. This exposes the action to supply-chain attacks if the upstream tag is moved or the repository is compromised. Failing references: `actions/checkout@v4`, `aws-actions/configure-aws-credentials@v4`, `hashicorp/setup-terraform@v3`. Each should be replaced with a full SHA pin, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `action.yaml:130`
- `action.yaml:134`
- `action.yaml:175`

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is interpolated directly inside a `run:` shell command. In the 'Print result' step, the line `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY` embeds the `steps.apply.outputs.public_url` context value directly into the shell command string. The `steps.*.outputs.*` context is workflow-controllable and passes through YAML template substitution before the shell processes it, enabling script injection if the output contains shell metacharacters. Fix: assign the value to an env var and reference it as a quoted shell variable, e.g. `env: PUBLIC_URL: ${{ steps.apply.outputs.public_url }}` then `echo "$PUBLIC_URL" >> $GITHUB_STEP_SUMMARY`.

Locations:

- `action.yaml:196`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed three unpinned `uses:` references by replacing mutable version tags with full 40-character commit SHAs (actions/checkout@v4→11d5960a..., aws-actions/configure-aws-credentials@v4→7474bc4..., hashicorp/setup-terraform@v3→b9cd54a...). Fixed script injection in the 'Print result' step by moving `${{ steps.apply.outputs.public_url }}` into an `env:` block as `PUBLIC_URL` and referencing it as the quoted shell variable `"$PUBLIC_URL"` in the run script.

