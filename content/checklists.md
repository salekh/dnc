# Monday-Morning Checklists: dintc Developer & Agent Playbook

This document contains step-by-step checklists to be executed every Monday morning by human architects, verifiers, and automated agents to ensure repository health, spec compliance, and system operational stability.

---

## 1. Human Architect & Developer Checklist

Execute these tasks manually at the start of the week:

- [ ] **Workspace Sync:** Sync your local Git workspace and resolve any divergent branches.
  ```bash
  git checkout main
  git pull origin main
  ```
- [ ] **Spec Drift Inspection:** Compare active design files against deployed versions.
  - Open `content/magenta-tv/spec.md` and check if there are any pending proposals or comments.
- [ ] **Static Quality Check:** Run the local unit-test and static analysis orchestrator to verify compile state.
  ```bash
  # Check python, C++, and Go targets
  mypy --strict content/
  black --check content/
  ```
- [ ] **Alerts & Oncall Handovers:** Check Buganizer queue and look for unresolved tickets under `MagentaTV-CW-Issues`.
  - Read `content/magenta-tv/runbook.md` to refresh on active incident scenarios.
  - Review the oncall log from the weekend rotation.

---

## 2. Automated Agent Verification Checklist

When an agent is booted at the start of the week, it must execute the following sequence:

- [ ] **Step 1: Codebase Interrogation**
  - Trigger the `/interrogate` route template to analyze if local target files have drifted from the master `spec.md`.
  - Input `content/prompts/interrogate.txt` with parameters.
- [ ] **Step 2: Dry-run Query Verification**
  - Run the `query-watch-history` skill in dry-run mode to confirm the BigQuery schemas have not changed.
  - Check query cost and latency parameters.
- [ ] **Step 3: Execute Load and Regression Tests**
  - Run latency test suites to ensure P99 continues to meet targets under load.
  ```bash
  rapid-cli test --target=//content/magenta-tv/... --type=load
  ```
- [ ] **Step 4: Report Status**
  - Output a weekly compliance report to `/var/log/weekly-dintc-report.json`.
