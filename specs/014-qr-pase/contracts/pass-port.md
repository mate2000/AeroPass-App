# Contract: Pass port and code source

`PassRepository` and `PassCodeSource` in `lib/domain/repositories/` (FR-001–FR-005, FR-011–FR-014,
FR-021; research.md §2, §4, §5).

## Wire format

```text
POST /v1/passes                    {enrollmentAttemptId, tripId}
  → {passId, nextCheckpoint: "security"|"boarding", validUntil, rotationSeconds, serverTime,
     secret?  (phase B only)}
GET  /v1/passes/{passId}/code      (phase A only)
  → {payload, windowStartsAt, windowEndsAt, serverTime}
GET  /v1/passes/{passId}/status
  → {state: "active"|"expired"|"revoked"|"boarded", validated: [...], nextCheckpoint,
     flightStatus: "on_time"|"delayed"|"cancelled"|"changed", serverTime}
```

## Mapping rules

| Input | Result |
|---|---|
| An unknown `state` | `Result.error`. A pass is never assumed active |
| An unknown checkpoint in `validated` or `nextCheckpoint` | Dropped from `validated`. An unknown `nextCheckpoint` is an error |
| `flightStatus` `cancelled` or `changed` | `PassState.flightChanged` |
| A `validUntil` later than 24 h after `serverTime` | Clamped to 24 h |
| A missing `serverTime` | `Result.error`, because the clock cannot be checked |
| `rotationSeconds` other than 30 | Accepted as given, but a value under 10 s or over 60 s is an error |
| No consent record | `Result.error`, and no request is sent |
| Transport failure | `TransportFailure` (011's mapper) |

## Code sources

| Source | Behavior |
|---|---|
| `BackendPassCodeSource` (A) | Fetches the current window's code. Offline, it is an error, and the screen shows `unavailable(offlineWithoutPass)` with the checkpoint line |
| `DerivedPassCodeSource` (B) | HMAC-SHA256 over `passId ‖ checkpoint ‖ window` with the stored secret, truncated to 16 bytes, giving `AP1.<passId>.<cp>.<window>.<b64url>`. It refuses when the clock is untrusted or `instant` is past `validUntil` |
| `DevPassCodeSource` | A synthetic payload per window, `AP1-DEV.<window>`, behind `USE_FAKE_VERIFICATION_BACKEND` |

## Tests (contract and unit, test-first per Principle IV)

1. Issue maps every field, clamps `validUntil`, and rejects a missing `serverTime` and an unknown
   state.
2. Status maps `validated` and `boarded`. `cancelled` gives `flightChanged`.
3. The derived source gives the same payload within one window and a different one in the next. It
   refuses past `validUntil` and under an untrusted clock. Its output matches a known test vector.
4. The backend source gives an error offline, never a stale payload.
5. `forget` removes the stored secret (phase B), and nothing else remains.
6. No payload, secret or pass id appears in any analytics event or log call. This is checked by the
   analytics payload test and a grep test on `developer.log`.
