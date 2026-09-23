# Contract: Credential summary port

`CredentialSummaryRepository` in `lib/domain/repositories/credential_summary_repository.dart` (FR-002,
FR-003, FR-009, FR-013; research.md §1–§3).

## Wire format (addendum to 001's status endpoint)

`GET /v1/credential/status` gains two optional fields:

```json
{ "status": "valid", "validUntil": "2031-09-23T00:00:00Z",
  "holderName": "Mateo González", "documentLast4": "4821" }
```

`status` also accepts `suspended`, which maps to `ExpiryReason.suspended`.

## Behavior of the real implementation

| Situation | `CredentialSummary` |
|---|---|
| Status read succeeds, `valid` | `active`, `confirmed: true`. Name and last4 from the response, or from storage if absent. The two fields are written to storage if they differ |
| Status read succeeds, `expired`, `revoked` or `suspended` | That state, `confirmed: true` |
| Status read fails, a token is stored | The state inferred from the stored validity (`active` if not past `validUntil`, else `expired`), with `confirmed: false`, and name and last4 from storage |
| Status read succeeds with no stored token | `Result.error(NoCredentialFailure)`. The screen goes to welcome |
| Nothing stored and the read fails | `Result.error` |

`documentLast4` is accepted only if it is exactly four digits. Anything else is treated as absent.
No other document digits are ever read, stored or rendered (FR-002).

## Storage changes (008 and 002)

- `CredentialService.writeCachedCredential` gains optional `holderName` and `documentLast4`. The
  issuance repositories, real and dev, pass them from the issuance response.
- `CredentialService.clearCachedCredential` deletes all four keys. Consent withdrawal (002, 008's
  change) already calls it.

## Implementations

| Implementation | Behavior |
|---|---|
| `CredentialSummaryRepositoryImpl` | The table above, over `CredentialService` |
| `DevCredentialSummaryRepository` | Behind `USE_FAKE_VERIFICATION_BACKEND`. With a stored token it returns `active`, `confirmed: true` and the stored fields, as the fake backend's affirmation; with none it returns `NoCredentialFailure` |
| `FakeCredentialSummaryRepository` (tests) | Scripted |

`DevCredentialRepository`, for 001's launch rule, uses the same stored token to return `valid`
instead of calling the nonexistent development URL (research.md §3).

## Contract tests

1. `valid` with fields gives `active` and `confirmed`, and stores the fields.
2. `valid` without fields falls back to the stored fields.
3. `suspended` gives the `suspended` state, and `revoked` and `expired` map likewise.
4. A transport failure with a stored token gives the inferred state with `confirmed: false`. It never
   gives `active` with `confirmed: true`.
5. A malformed `documentLast4`, such as "48211" or "48a1", is treated as absent.
6. `clearCachedCredential` removes all four keys.
