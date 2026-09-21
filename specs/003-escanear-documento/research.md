# Phase 0 Research: Identity Document Capture (03 Escanear documento)

## 1. Camera access

**Decision**: The official `camera` Flutter package (`pub.dev/packages/camera`, maintained by the
Flutter team), used for the live preview, torch control, and manual still capture.

**Rationale**: There is no way to access the device camera from Dart without a platform-channel
plugin — this isn't optional the way some other dependencies in this app have been. `camera` is the
Flutter-team-maintained option, supports both target platforms at or above the app's Android
8.0/iOS 15.0 baseline, exposes torch control and resolution presets directly (no extra plugin
needed for FR-005), and returns captured frames in memory (as `XFile`/bytes) without requiring a
gallery-saving step — which matters directly for FR-010's "never written to disk" requirement: the
plugin's own capture call can be pointed at a temp path, but the *service* wrapping it must read the
bytes into memory and delete that temp file immediately, never surface it, and never let it survive
past the capture call (see data-model.md's `DocumentImage`).

**Alternatives considered**: `camerawesome` or other third-party camera UI kits (rejected — they
bundle a lot of UI/UX opinion this screen's design already fully specifies, and add more surface
area than a single capture call needs); native platform channels written by hand (rejected —
reinventing what `camera` already solves, for both platforms, well).

## 2. On-device quality assessment (blur, glare, framing, resolution, wrong document)

**Decision**: Heuristic, not ML-model-based. Computed directly from the captured frame's pixel data
using cheap, well-understood signal-processing checks:
- **Blur**: variance of the Laplacian (edge-strength) over a luma-converted downsample of the frame
  — a low variance means few sharp edges, i.e. blur.
- **Glare**: percentage of pixels at or near maximum luma (blown-out highlights) within the framing
  guide's region — a high percentage indicates glare/reflection.
- **Framing**: edge/contour detection within the framing guide's region, checking that a
  document-shaped rectangle occupies a minimum proportion of the frame and isn't cropped at the
  guide's boundary.
- **Resolution**: a simple minimum-pixel-dimension check against the capture's actual output size
  (the `camera` plugin's resolution preset already targets a size well above this floor; this is a
  cheap safety check, not the primary control).
- **Wrong document**: the framing check's aspect-ratio comparison against the two accepted document
  shapes (cédula card ratio, passport biodata-page ratio) — a captured shape matching neither is
  classified as a wrong-document rejection rather than a framing rejection, giving the passenger the
  correct actionable message (FR-019).

**Rationale**: A real OCR/authenticity model is explicitly the external processor's job (spec.md Out
of Scope) — this device-side gate exists only to catch the *obviously* unusable cases cheaply and
instantly (SC-003's ≥90% target), not to approach the processor's accuracy. Bundling a TFLite model
or an ML Kit dependency for this would be exactly the kind of speculative generality the
constitution's KISS guidance rejects: heuristics computed in a few dozen lines of Dart, running in
well under the SC-002 time budget, get most of the value (blur and glare are the two most common
real-world failure modes named in the spec's own rationale) without a model-management,
model-size, or model-accuracy-drift problem to own.

**Alternatives considered**: Google ML Kit Document Scanner (rejected — a much larger dependency
with its own permission/licensing surface, for a device-side *pre-filter* whose whole job is to be
cheap and fast, not authoritative); shipping no device-side check at all and relying entirely on the
processor (rejected — directly contradicts FR-006/SC-003, and defeats the cost-control purpose named
throughout the spec).

**Abstraction boundary**: `DocumentQualityAssessor` is a domain port with one method,
`assess(bytes) -> QualityAssessment`, so the heuristic implementation can be swapped for a
model-based one later (e.g. if real-world SC-001/SC-003 numbers show the heuristics underperform)
without touching `CaptureViewModel`.

## 3. Capture-attempt counter persistence

**Decision**: `flutter_secure_storage`, the same store already used for the credential and consent
record, holding two new keys: an integer count and a last-reset ISO-8601 timestamp. No new storage
dependency.

**Rationale**: The constitution's Principle I amendment (this planning session) explicitly names
this as allowed persisted state. Reusing the existing secure-storage instance avoids adding
`shared_preferences` or any other storage package for a two-field counter — even though the counter
itself isn't sensitive data, there's no cost to keeping it in the one storage tier the app already
has, and it avoids a second storage mechanism to reason about.

**Reset semantics**: "per enrollment step it protects" (constitution's amended wording) — a fresh
`lastResetAt` is written whenever the passenger successfully completes this step (submits an
accepted capture) or is explicitly routed to retry guidance, so a *future* enrollment attempt
(e.g., after a successful capture, session ends, and months later the passenger re-enrolls for a new
credential) starts with a clean counter rather than inheriting a stale one from an unrelated past
attempt.

**Alternatives considered**: `shared_preferences` (rejected — new dependency for no benefit over
reusing existing secure storage); a backend-tracked counter (rejected — spec.md's Assumptions
explicitly scope this to local/session tracking, not cross-device/backend rate limiting, which is
out of scope).

## 4. Verification outcome translation (FR-008)

**Decision**: `DocumentVerificationRepository.submit(bytes) -> Result<CaptureOutcome>`, where
`CaptureOutcome` is a sealed type with variants `accepted` and `rejected(reason)`, and `reason` is
drawn from the **same** `QualityRejectionReason`-shaped vocabulary the on-device assessor uses
(blur, glare, framing, wrongDocument) plus one processor-only variant, `unreadable`, for whatever the
processor rejects that the device-side heuristics didn't catch. The service layer maps the
processor's actual error taxonomy into this fixed, small enum — no processor error string or code
ever reaches `CaptureViewModel` or the UI.

**Rationale**: FR-008 requires "the same actionable vocabulary as device-side rejections" — sharing
one sealed type between the device-side and processor-side rejection paths is what makes that
requirement mechanically true (Principle IX: a sealed type can't be switched over incompletely
without the analyzer objecting) rather than something that has to be remembered case-by-case across
two different error models.

**Alternatives considered**: Two separate enums (device vs. processor rejection reasons) with a
manual mapping table at the UI layer (rejected — exactly the kind of duplicated-knowledge DRY
violation the constitution's craft standards call out; a passenger-facing message should have one
definition, not two enums that happen to be kept in sync by convention).

## 5. Camera lifecycle (backgrounding, interruption, lock)

**Decision**: `CaptureViewModel` observes app lifecycle via a `WidgetsBindingObserver` composed at
the view level (standard Flutter pattern, no new dependency) and calls
`CameraCaptureService.stop()`/`dispose()` on `AppLifecycleState.paused`/`inactive`, discarding any
held (not-yet-submitted) in-memory capture. On resume, the preview is re-initialized fresh — never
resuming with a stale/frozen frame.

**Rationale**: This is exactly the Edge Cases requirement ("the camera stops and any held image is
discarded; on return the passenger starts the capture again") and the "never presents a frozen frame
as a live preview" requirement — both satisfied by the same lifecycle-driven stop/reinit, no new
machinery needed beyond what Flutter's own widget lifecycle already offers.

**Alternatives considered**: Keeping the camera controller alive across backgrounding and just
pausing the preview widget (rejected — platforms reclaim camera hardware access when backgrounded
regardless, so a "paused but alive" controller is not a real option on either target platform; the
stop/reinit approach matches what actually happens at the OS level).
