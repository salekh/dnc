# Master Specification: Ruby TV "Continue Watching" Engine

This master specification coordinates all components of the Ruby TV Continue Watching recommendation service. It acts as the single source of truth (SSoT) tying together product requirements, technical design, implementation schedules, agent guidelines, and operational runbooks.

---

## 1. Document Directory Map

The Ruby TV personalized serving service codebase is structured under `/content/ruby-tv/`:

- **[prd.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/prd.md):** Defines target user stories, non-goals, and numeric metrics.
- **[design.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/design.md):** Defines the UI/UX layout, wireframe, and API contracts.
- **[plan.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/plan.md):** The 6-phase RPI implementation plan.
- **[GEMINI.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/GEMINI.md):** Banned libraries, house style guide, and sandbox boundaries.
- **[runbook.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/runbook.md):** The incident triage playbooks and remediation recipes.
- **Skills/Runbooks:**
  - **[deploy-recs-service.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/skills/deploy-recs-service.md):** Declarative deploy steps.
  - **[query-watch-history.md](file:///usr/local/google/home/sanchitalekh/Code/dnc/content/ruby-tv/skills/query-watch-history.md):** SQL lookup template.

---

## 2. Integrated Architecture Flow

The system flows through a fast-path cache layer and a slow-path database layer, governed by user profiles.

```
       +-----------------------+
       |   User Profile Request|
       +-----------------------+
                   |
                   v
       +-----------------------+        Yes        +-------------------------+
       |   Is Cache Hit?       | ----------------> | Return Rails payload    |
       +-----------------------+                   +-------------------------+
                   | No
                   v
       +-----------------------+
       | Run BigQuery query-   | <--- Uses [query-watch-history.md] SQL template
       | watch-history skill   |
       +-----------------------+
                   |
                   v
       +-----------------------+
       | Populate Redis Cache  |
       +-----------------------+
                   |
                   v
       +-----------------------+
       | Return Rails payload  |
       +-----------------------+
```

### Components and Integrations

1. **The Ingestion Pipeline:** 
   - Receives raw watch event data from client players.
   - Cleans and filters out records according to *PRD User Story 2* (automatic cleanup of completed items where watch percentage >= 90%).
   - Stores clean history records in BigQuery.

2. **The Serving Path:**
   - Client makes requests to `GetContinueWatching` defined in `design.md`.
   - The serving microservice inspects the Cache. If present, returns data instantly.
   - On cache miss, it calls the `query-watch-history` BigQuery lookup, runs ranking calculations, and saves context back into the Cache.

3. **Multi-User Isolation:**
   - Follows *PRD User Story 3*. Cache keys are split: `cw:{user_id}:{profile_id}`. 
   - No data overlaps.

---

## 3. Evaluation-to-Verification Mapping

To guarantee that the implementation is production-ready, our automated testing suites must verify each target metric before a rollout is promoted:

| PRD Metric Target | Test Suite | Verification Location | Code Reference |
| :--- | :--- | :--- | :--- |
| **Latency <= 45ms** | `recs_latency_test` | `plan.md` Phase 5 | `infra/tests:latency_test` |
| **CTR Lift >= 3.5%** | `ctr_ab_evaluation` | `plan.md` Phase 5 | `infra/tests:ctr_eval` |
| **Hallucination <= 0.5%** | `hallucination_check` | `plan.md` Phase 5 | `infra/tests:accuracy_eval` |
| **Sync Delay <= 2.0s** | `sync_latency_test` | `plan.md` Phase 5 | `infra/tests:sync_eval` |

If any of these verification suites report failures, the `deploy-recs-service` skill will trigger a rollback.

---

## 4. Operational Safety & Incident Loops

During runtime, the monitoring system queries latency and error parameters. When alerts fire, agents use the following resolution steps matching the `runbook.md` recipes:

```
[ Alert Fire ]
       |
       v
[ Agent Read Runbook.md ]
       |
       v
[ Execute Diagnostics ] --(Cache Failure?)--> [ Fallback to BigQuery replica ]
       |                                                 |
       | (Ingestion delay?)                              | (OOM Crash?)
       v                                                 v
[ Scale Ingestion Worker ]                       [ Rolling Pod Restart ]
```

Every remediation must follow the safety guidelines in `GEMINI.md` to prevent escalation of service degradation.
