# Incident Playbook: Continue Watching serving-service (runbook.md)

This runbook describes how to diagnose and remediate common production incidents for the `recs-serving-service`.

---

## Incident Matrix

| Symptom | Primary Diagnosis | Immediate Remediation |
| :--- | :--- | :--- |
| **P99 Serving Latency > 100ms** | Redis Cache Layer Outage / Hotspot | Fallback to BigQuery replication replica / scale cache nodes |
| **Hallucination Rate > 2.0%** | Sync Pipeline lag or stale watch events stream | Trigger pipeline checkpoint reset / flush active task queues |
| **Error Rate (gRPC 5xx) > 1.0%** | Out-of-memory (OOM) crashes in pods | Execute immediate pod rolling restart / increase RAM limit |

---

## 1. Symptom: Latency Spike (P99 > 100ms)

### Diagnosis:
1. Verify cache hit rate on the Redis instance.
   ```bash
   redis-cli -h cw-cache-redis INFO stats | grep keyspace
   ```
2. If hit rate is `< 20%`, check if the Cache Writer service is dead or stuck.
3. Check CPU/Memory metrics on Redis pods.

### Remediation:
1. If the cache is down, enable read-through direct querying to the BigQuery replica (read-only backup):
   ```bash
   rapid-cli config set --service=recs-serving-service --flag=enable_bq_fallback=true
   ```
2. Restart the cache writer service to resume cache populating:
   ```bash
   rapid-cli restart-deployment --service=cw-cache-writer
   ```

---

## 2. Symptom: Elevated Hallucination Rate (> 2.0%)

### Diagnosis:
1. Check ingestion logs for the watch history Kafka/PubSub topics.
2. Calculate delay in message processing.
   ```bash
   pubsub-cli metrics lag-time --topic=watch-history-events
   ```

### Remediation:
1. If PubSub lag is high, scale up the ingestion consumer deployment to process the backlog:
   ```bash
   rapid-cli scale --service=watch-history-consumer --replicas=30
   ```
2. If corrupt records are causing parsing loops, execute a message skip action (per instruction in task-docs):
   ```bash
   pubsub-cli skip-corrupt --topic=watch-history-events --offset=latest
   ```

---

## 3. Symptom: gRPC Error Rate Spill (5xx Errors)

### Diagnosis:
1. Run container check to verify exit code of dead pods.
   ```bash
   kubectl get pods -n rubytv-prod -l app=recs-serving-service
   ```
2. Look for `OOMKilled` (Exit Code 137).

### Remediation:
1. Restart the deployment to clear out leaks:
   ```bash
   rapid-cli restart-deployment --service=recs-serving-service
   ```
2. Apply emergency memory limits increase (scale resource config):
   ```bash
   rapid-cli update-resources --service=recs-serving-service --memory=4Gi
   ```
