# Product Requirement Document (PRD): MagentaTV "Continue Watching" Personalization Service

## 1. Overview
The "Continue Watching" rail is the central navigational element on the MagentaTV homescreen. It helps users resume content they have previously started, including movies, episodic TV shows, and live TV broadcasts. This PRD defines the requirements for upgrading this rail from a simple timestamp-sorted list to a personalized, context-aware recommendation service that optimizes for user retention and completion rates.

---

## 2. User Stories

### User Story 1: Resuming an Episode of a TV Series
> **As a** MagentaTV subscriber,  
> **I want** the "Continue Watching" rail to display the next episode of the TV series I am currently watching, rather than the episode I just finished, and start it from the beginning,  
> **So that** I can seamlessly continue my binge-watch experience without manually browsing through the series detail page.

### User Story 2: Cleaning Up Completed Content
> **As a** casual viewer,  
> **I want** content where I have watched more than 90% (or completed the credit sequence) to automatically disappear from the "Continue Watching" rail,  
> **So that** my rail is not cluttered with movies and episodes I have already finished.

### User Story 3: Multi-User Profile Isolation
> **As a** member of a multi-user household,  
> **I want** my watch history and "Continue Watching" rail to be completely isolated under my profile,  
> **So that** I do not see recommendations for the sports broadcasts or cartoons my kids or spouse are watching.

### User Story 4: Cross-Device Sync
> **As a** mobile and smart TV viewer,  
> **I want** my watch position in a movie to sync within 5 seconds of pausing on my mobile phone,  
> **So that** when I turn on my MagentaTV smart TV app in the living room, I can resume the movie from the exact same frame.

---

## 3. Non-Goals

1. **New User Discovery:** This service will not recommend brand new shows or movies that the user has never started. It is strictly limited to content with an active watch history.
2. **Offline Mode Synchronization:** Local playback bookmarks recorded while a device is offline will not be synced in real-time. They will only be processed upon next internet reconnection.
3. **Ads and Promo Placement:** The "Continue Watching" rail will not contain sponsored content, advertisements, or promotional banners. It is reserved exclusively for the user's active watch history.

---

## 4. Evaluation Metrics & Numeric Targets

To verify that the synthesized recommendation service meets our business and quality standards, the service must pass the following evaluations:

### Eval 1: P99 Serving Latency
* **Metric:** Time from request receipt to response delivery under load.
* **Target:** P99 Latency must be **<= 45ms** at a simulated load of 15,000 queries per second (QPS).

### Eval 2: Click-Through Rate (CTR) Lift
* **Metric:** Total clicks on the Continue Watching rail divided by total impressions of the rail.
* **Target:** CTR must show a **>= +3.5%** relative lift compared to the current timestamp-sorted baseline in A/B testing.

### Eval 3: Recommendation Hallucination Rate
* **Metric:** Percentage of items in the Continue Watching rail that the user has either never watched, or has already fully completed (watched >95% including credits).
* **Target:** Hallucination rate must be **<= 0.5%** over a validation dataset of 1,000,000 historic profiles.

### Eval 4: Watch History Synchronization Delay
* **Metric:** Delay between the termination of a playback session on Client A and the availability of the updated resume point in the API response for Client B.
* **Target:** P95 Sync Latency must be **<= 2.0 seconds** under normal network conditions.

### Eval 5: Cold Start Fallback Precision
* **Metric:** Accuracy of recommendation ordering when a profile has less than three active watch events (reverting to popular trends within the same geo).
* **Target:** Precision@3 must be **>= 75.0%** for new users during simulated profiles.
