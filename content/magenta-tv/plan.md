# Implementation Plan: 6-Phase RPI Breakdown

This plan defines the step-by-step rollout of the personalized "Continue Watching" recommendation engine, following the **RPI (Research, Plan, Implement)** methodology.

---

## The 6-Phase RPI Matrix

```
+-----------------------------------------------------------------------------------+
|  Phase 1: Requirements & Research (R)                                            |
|  - Define baseline metrics, target user counts, and query schemas.                 |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|  Phase 2: Architectural Planning (P)                                              |
|  - Define gRPC/Protobuf schemas, cache layouts, and database indexes.             |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|  Phase 3: Prototyping & Skill Verification (I)                                    |
|  - Run and verify standard BigQuery query-watch-history and deploy skills.       |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|  Phase 4: Core Implementation & Integration (I)                                   |
|  - Implement serving logic, Redis caching policies, and event consumer loops.      |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|  Phase 5: Automated Verification & Evals (I)                                      |
|  - Execute load tests, CTR validations, and latency audits.                       |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|  Phase 6: Rollout & Incident Monitoring (I)                                       |
|  - Deploy to staging/canary cells, monitor runbooks, and perform handovers.       |
+-----------------------------------------------------------------------------------+
```

---

## Phase Details

### Phase 1: Requirements & Research
- **Objective:** Map user requirements to existing watch history data schemas in BigQuery.
- **Tasks:** 
  - Benchmark current serving path P99 latency baseline (currently ~80ms with non-personalized queries).
  - Define user cohort sizes for testing.

### Phase 2: Architectural Planning
- **Objective:** Establish interface contracts and cache design.
- **Tasks:**
  - Create proto definitions for `GetContinueWatching`.
  - Design the Redis key schema: `cw:{user_id}:{profile_id}` with TTL of 1 hour.

### Phase 3: Prototyping & Skill Verification
- **Objective:** Test agent capabilities against environment queries and deployment runbooks.
- **Tasks:**
  - Execute the `query-watch-history` BigQuery skill in dry-run mode.
  - Verify that the target SQL returns correct watch intervals.

### Phase 4: Core Implementation & Integration
- **Objective:** Synthesize the recommendation service code.
- **Tasks:**
  - Build the Go/C++ service loop reading from the database and updating the Redis cache.
  - Wire up client-side synchronization events.

### Phase 5: Automated Verification & Evals
- **Objective:** Validate that the system satisfies the numeric targets.
- **Tasks:**
  - Run the `recs_latency_test` load test under 15,000 QPS load.
  - Verify that the hallucination rate remains below 0.5% on baseline logs.

### Phase 6: Rollout & Incident Monitoring
- **Objective:** Deploy safely and configure runtime protections.
- **Tasks:**
  - Trigger canary deployment via the `deploy-recs-service` skill.
  - Validate runbooks by simulating a high-latency response incident on the cache store.
