# Notification Scheduling – Test Findings & Edge Cases

This document summarizes testing of the notification scheduling behavior in the app, including bugs found and edge cases to consider.

---

## Bugs Found & Fixed

### 1. **Notification ID collision (fixed)**

**Location:** `lib/commons/notification/event_notification_scheduler.dart` – `_notificationId()`

**Issue:** IDs were computed as `(hash & 0x7FFFFFFF) + type.idBase` with `idBase` 1000 and 2000. The hash range is 0..2^31-1, so the two types produced overlapping ID ranges. Two different (eventId, type) pairs could get the same notification ID, so cancelling one event’s notification could cancel another’s.

**Fix:** Use non-overlapping ranges: `type.idBase + (hash % 999000)`, and set `eventStart.idBase` to `1000000` so ranges are [1000, 999999] and [1000000, 1998999].

---

## Remaining Issues & Edge Cases

### 2. **Timezone handling (potential bug)**

**Location:** `event_notification_scheduler.dart` – `scheduleForEvent()`

**Issue:** `event.startDateTime` is parsed with `DateTime.parse()` from the API (often ISO 8601 UTC). The code does:

- `scheduledAt = eventStart.subtract(type.offset)` (uses that DateTime as-is)
- `tz.TZDateTime.from(scheduledAt, tz.local)` (interprets it as **local** time)

If the API sends UTC, the scheduled time is wrong (e.g. “8:00 PM UTC” is treated as “8:00 PM local”).

**Recommendation:** Clarify API contract: if `startDateTime` is UTC, convert to local before building `TZDateTime`, e.g. `tz.TZDateTime.from(scheduledAt.toLocal(), tz.local)` (or use a timezone from event if you add one).

---

### 3. **Fire-and-forget scheduling in event_service**

**Location:** `lib/service/event_service.dart` – RSVP update, `_updateEvent`, `_addEvent`

**Issue:** `scheduleForEvent()` and `cancelForEvent()` are called without `await`. Failures are silent and the UI can continue before notifications are updated.

**Recommendation:** Await scheduler calls and optionally surface or log errors so retries or user messaging can be added later.

---

### 4. **syncAll with empty event list cancels all notifications**

**Location:** `event_notification_scheduler.dart` – `syncAll()`, and `base_screen.dart` – `syncAll(events, user)`

**Issue:** When `events` is empty, the first loop does nothing and `seenIds` stays empty. The cleanup loop then cancels every pending notification whose payload contains an `eventId` (i.e. all app-scheduled event notifications). So a transient empty list (e.g. slow load, or bug) can wipe all scheduled notifications.

**Recommendation:** Either avoid calling `syncAll` when the list is empty, or only call `syncAll` when you have a “final” list (e.g. after a successful fetch), and document that empty list means “user has no events, cancel all.”

---

### 5. **Partial failure in syncAll leaves state inconsistent**

**Location:** `event_notification_scheduler.dart` – `syncAll()`

**Issue:** For each event we `cancelForEvent()` then `scheduleForEvent()`. If `scheduleForEvent()` throws or fails for one type (e.g. permission), we’ve already cancelled that event’s notifications and don’t reschedule them. Exceptions are swallowed in `scheduleForEvent()`, so the app doesn’t know.

**Recommendation:** Consider scheduling first (e.g. to a temp set of IDs) then cancelling old ones, or track failures and retry / log so state stays consistent.

---

### 6. **Concurrent syncAll races**

**Location:** `base_screen.dart` – `addPostFrameCallback` calls `syncAll()`

**Issue:** If the widget rebuilds and the callback runs multiple times, or if another code path calls `syncAll()` at the same time, two concurrent `syncAll()` runs can interleave cancel/schedule and leave a wrong set of pending notifications.

**Recommendation:** Serialize `syncAll()` (e.g. a single “pending sync” future and coalesce calls, or a lock) so only one runs at a time.

---

### 7. **Duplicate event IDs in syncAll list**

**Location:** `event_notification_scheduler.dart` – `syncAll()`

**Issue:** If `events` contains the same `event.id` twice (e.g. bug or duplicate data), we process both; the second overwrites the first in effect. Order of the list can determine which event data “wins.” No functional bug if data is identical, but redundant work and potential confusion if data differs.

**Recommendation:** Deduplicate by `event.id` before iterating, or document that the list must be unique by id.

---

## Edge Cases Covered by Tests

- **Eligibility:** null user, null/empty event id, null/past start time, GOING/MAYBE/host → schedule; NOT_GOING/UNDECIDED/non-host → no schedule.
- **Payload parsing:** null, empty, invalid JSON, missing `eventId`, valid `eventId`, type mismatch (e.g. numeric `eventId`) → correct null or value.
- **Notification ID ranges:** `eventStart.idBase >= 1000000` so it does not overlap with `twoHourReminder` range.

---

## Recommendations Summary

1. Fix timezone handling if API sends UTC.
2. Await and optionally handle errors for scheduler calls in `event_service`.
3. Avoid or carefully define behavior when calling `syncAll` with an empty list.
4. Harden `syncAll` against partial failure and concurrency (serialize, consider schedule-then-cancel or retries).
