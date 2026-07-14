# Technical Design Document: "Continue Watching" Personalization Engine

This document details the system design, API contracts, and user interface layouts for the personalized "Continue Watching" service.

---

## 1. User Interface: Continue Watching Rail

The UI component is rendered as a horizontal scrollable rail on the Ruby TV homescreen. Below is the ASCII wireframe showing the layout with title, progress indicators, episode numbers, and personalized recommendation tags.

```
+-----------------------------------------------------------------------------------------------------------------+
|                                                                                                                 |
|  CONTINUE WATCHING                                                                                              |
|                                                                                                                 |
|  +---------------------------+   +---------------------------+   +---------------------------+   +-----------+  |
|  | ######################### |   | ######################### |   | ######################### |   | ######### |  |
|  | ######################### |   | ######################### |   | ######################### |   | ######### |  |
|  | ####### [THUMBNAIL] ##### |   | ####### [THUMBNAIL] ##### |   | ####### [THUMBNAIL] ##### |   | [THUMBN]  |  |
|  | ######################### |   | ######################### |   | ######################### |   | ######### |  |
|  | ######################### |   | ######################### |   | ######################### |   | ######### |  |
|  |                           |   |                           |   |                           |   |           |  |
|  | [===========o------------] |   | [=============o----------] |   | [=======o----------------] |   | [======o  |  |
|  |  (82% Watched)            |   |  (65% Watched)            |   |  (40% Watched)            |   |  (30% Wa  |  |
|  |                           |   |                           |   |                           |   |           |  |
|  | The White Lotus           |   | Succession                |   | Dune: Part Two            |   | Severance |  |
|  | Season 2, Ep 4            |   | Season 4, Ep 1            |   | Movie                     |   | Season 1  |  |
|  |                           |   |                           |   |                           |   |           |  |
|  | [Next Episode Available]  |   | [Recently Active]         |   | [Resume Movie]            |   | [Next Ep] |  |
|  +---------------------------+   +---------------------------+   +---------------------------+   +-----------+  |
|                                                                                                                 |
+-----------------------------------------------------------------------------------------------------------------+
```

---

## 2. API Contract

The recommendation service exposes the `GetContinueWatching` gRPC and REST endpoint.

### Request Payload
```json
{
  "user_id": "usr_9028188603",
  "profile_id": "prof_3883259",
  "client_metadata": {
    "device_type": "SMART_TV",
    "os_version": "tvos-17.4",
    "app_version": "v12.4.1"
  },
  "limit": 10
}
```

### Response Payload
```json
{
  "rail_title": "Continue Watching for Sarah",
  "items": [
    {
      "content_id": "series_white_lotus_s2_ep4",
      "display_title": "The White Lotus",
      "subtitle": "Season 2, Episode 4 - 'In the Sandbox'",
      "thumbnail_url": "https://images.ruby-tv.de/thumbs/wl_s2_e4.jpg",
      "watch_progress_percentage": 82.5,
      "last_watched_timestamp": 1783459200,
      "resume_offset_seconds": 2970,
      "contextual_tag": "NEXT_EPISODE_AVAILABLE",
      "action_url": "rubytv://play?id=series_white_lotus_s2_ep4&t=2970"
    }
  ]
}
```

---

## 3. High-Level Architecture

The service runs in a distributed microservice cluster, utilizing memory caches and streaming event logs.

```
                  +--------------------------------+
                  |           Client App           |
                  +--------------------------------+
                                  |
                        (GetContinueWatching)
                                  v
                  +--------------------------------+
                  |      Recs Serving Service      |
                  +--------------------------------+
                     |                          |
       (Query Cache: Redis)            (Query BigQuery)
                     |                          |
                     v                          v
          +--------------------+      +--------------------+
          |  Fast Cache Store  |      |   Watch History    |
          |  (Recent Session)  |      |   (Raw DB / Lake)  |
          +--------------------+      +--------------------+
```
