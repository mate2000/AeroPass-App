# Contract: `IdentityRecordRepository`

Per research.md §5 and FR-017.

## Interface

```text
abstract class IdentityRecordRepository {
  Future<Result<IdentityRecord>> confirm(IdentityRecord record);
}
```

- Submits the full `IdentityRecord` (every field's value, `FieldSource`, and — for a corrected field —
  its original value and whether it was automatically re-verified) to the backend. Mirrors
  `ConsentRepositoryImpl.recordConsent()`'s shape: submit first; only a backend success makes anything
  durable.
- On `Ok`, the implementation additionally writes a **display-only subset** (each field's `key`+`value`
  only — no `source`, no `originalValue`, no `reverified` flag) to `flutter_secure_storage`, under a new
  key distinct from every existing one (consent record, credential token, capture-attempt counter).
  This is the one new persisted-state category this feature introduces, and it is already named in the
  Constitution's Principle I allowlist ("a display-only subset of identity fields the user already saw
  on the confirmation screen") — no constitution amendment required.
- On `Error` (offline, timeout, backend rejection), nothing is written locally — FR-017's "where it
  cannot be recorded, the flow MUST NOT advance."

## Contract test suite

1. Backend accepts the record → `Ok(IdentityRecord)`, and a subsequent read of the local display-only
   cache returns exactly the submitted fields' `key`+`value` pairs — no source/original/reverified data
   present in what was written locally.
2. Backend rejects or is unreachable → `Error`; the local cache is untouched (no partial write).
3. A record containing an `unresolved`-status field is never constructed by the ViewModel in the first
   place (FR-007) — this repository is never called with one; no defensive handling of that case is
   part of this contract.

## Fake implementation

Scripted responses, no network — same pattern as `FakeConsentRepository`. Exposes the same
"read the local cache back" capability the real implementation provides, so tests can assert on
exactly what got cached.

## Real implementation

`IdentityRecordService` (certificate-pinned `dio`, reusing `buildPinnedDio`, plus
`flutter_secure_storage` for the local write) + `IdentityRecordRepositoryImpl`. No `dio` exception, DTO,
or raw JSON shape crosses into `DocumentConfirmationViewModel` — callers only ever see
`IdentityRecord`/`Result`.
