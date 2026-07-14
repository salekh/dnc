---
name: query-watch-history
description: Query user watch history from BigQuery to extract active session metrics and progress offsets.
---

# Query Watch History Skill

This skill allows agents to retrieve structured watch history profiles to compute recommendation targets and cold-start fallbacks.

## 1. SQL Template: Get Active Sessions

Execute the following query to extract the top active watch events for a user profile:

```sql
-- Parameters:
-- @UserId: STRING
-- @ProfileId: STRING
-- @Limit: INT64

SELECT
  user_id,
  profile_id,
  content_id,
  content_type,
  episode_number,
  season_number,
  watch_offset_seconds,
  duration_seconds,
  (watch_offset_seconds / duration_seconds) * 100 AS progress_percentage,
  last_active_timestamp
FROM
  `ruby-tv-data.history.watch_events`
WHERE
  user_id = @UserId
  AND profile_id = @ProfileId
  -- Filter out completed content (> 90% watched)
  AND (watch_offset_seconds / duration_seconds) < 0.90
  -- Limit tracking to events within the last 30 days
  AND last_active_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
ORDER BY
  last_active_timestamp DESC
LIMIT
  @Limit;
```

## 2. Dry-Run Execution

Always dry-run queries before running them against production datasets to estimate cost and verify schema alignment.

```bash
bq query \
  --use_legacy_sql=false \
  --dry_run \
  --parameter=UserId:STRING:usr_9028188603 \
  --parameter=ProfileId:STRING:prof_3883259 \
  --parameter=Limit:INT64:5 \
  < sql/get_active_sessions.sql
```
