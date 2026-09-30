<!-- markdownlint-disable -->

# Hardening Report: bitovi--github-actions-deploy-static-site-to-aws/v0.2.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **bitovi--github-actions-deploy-static-site-to-aws/v0.2.10** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Three `uses:` references in action.yaml are pinned to mutable version tags instead of immutable 40-character commit SHAs. This exposes the action to supply-chain attacks if the upstream tag is moved or the repository is compromised. Failing references: `actions/checkout@v4`, `aws-actions/configure-aws-credentials@v4`, `hashicorp/setup-terraform@v3`.

Locations:

- `action.yaml:131`
- `action.yaml:135`
- `action.yaml:185`

### script-injection (severity: high)

Sub-rule (a): A `${{ }}` expression is interpolated directly inside a `run:` shell command string in the 'Print result' step. The offending line is: `echo ${{ steps.apply.outputs.public_url }} >> $GITHUB_STEP_SUMMARY`. The `steps.*.outputs.*` context flows through YAML template substitution before the shell processes it, allowing an attacker who can influence the terraform output (e.g. via a malicious resource name) to inject arbitrary shell commands. The value should be passed via an `env:` variable and double-quoted in the shell.

Locations:

- `action.yaml:222`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed three unpinned action references by resolving their mutable version tags to immutable 40-character commit SHAs (actions/checkout@v4→11d5960a, aws-actions/configure-aws-credentials@v4→7474bc4, hashicorp/setup-terraform@v3→b9cd54a). Fixed script injection in the 'Print result' step by moving ${{ steps.apply.outputs.public_url }} into an env: block as PUBLIC_URL and referencing it as "$PUBLIC_URL" in the shell script.

