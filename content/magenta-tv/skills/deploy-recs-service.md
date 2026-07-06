---
name: deploy-recs-service
description: Deploy the MagentaTV recommendations service to target environments, manage canaries, and configure rollbacks.
---

# Deploy Recommendations Service Skill

This skill allows agents to execute, monitor, and rollback deployments of the MagentaTV `recs-serving-service`.

## 1. Setup & Configuration

Ensure your environment has access to the deployment control tool `rapid-cli` (mocked in sandbox environments).

```bash
# Verify cluster authentication
rapid-cli cluster-status --cluster=magentatv-staging-cell-1
```

## 2. Deployment Steps

To deploy a new container version of the serving service:

### Step 1: Deploy to Staging Canary
Deploy the target candidate build image with a 5% traffic canary rate.

```bash
rapid-cli deploy \
  --service=recs-serving-service \
  --image=gcr.io/magenta-tv/recs-service:v2.1.0-rc3 \
  --environment=staging \
  --canary_percent=5 \
  --timeout_seconds=300
```

### Step 2: Verification
Monitor the deployment metrics for 3 minutes.
- Success criteria: P99 latency < 45ms, Error rate < 0.01%.

```bash
rapid-cli monitor \
  --service=recs-serving-service \
  --environment=staging \
  --duration=180s
```

### Step 3: Promote Release
If verification succeeds, promote the deployment to 100% traffic in the target cells.

```bash
rapid-cli promote \
  --service=recs-serving-service \
  --environment=staging
```

## 3. Rollback Procedure
If latency spikes or error rates exceed 0.5%, immediately abort the deployment and restore the previous stable candidate.

```bash
rapid-cli rollback \
  --service=recs-serving-service \
  --environment=staging \
  --reason="Latency spike in canary"
```
