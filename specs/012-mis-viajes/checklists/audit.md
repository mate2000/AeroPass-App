# Trust-Boundary Audit: Trips Home (12 Mis viajes)

**Task**: T041 | **Date**: 2026-09-23 | **Method**: repository search, backed by the tests named below

These are findings, not a reviewer checklist, so they use no checkboxes.

## No itinerary is stored on the device (FR-013, CONFLICT-005)

- There is no write call in:
  - `lib/features/trips/` and `lib/features/profile/`;
  - the trip service and repository;
  - the dev trip repository;
  - the trip entities.

  The search covered `write(`, `writeAs…` and `SharedPreferences`.
- The last good snapshot is a field of the repository instance, in memory only.
- `test/architecture/import_boundary_test.dart` now forbids the trips and Perfil features from
  importing the data layer, secure storage, shared preferences, path_provider or `dart:io`.
- The only new stored values are the holder name and the last four digits. Both are display-only
  identity fields on the constitution's allowlist. They are cleared with the token
  (`credential_summary_repository_contract_test.dart`, case 6).

## "ACTIVA" only from a backend affirmation (FR-003, SC-006)

- The badge text "ACTIVA" is rendered only through `CredentialSummary.showsActive`, which requires
  `state == active && confirmed`.
- An unconfirmed active credential reads "SIN CONFIRMAR". Other unconfirmed states read
  "{STATE} · sin confirmar".
- The widget tests assert that no non-affirmed summary contains the word "ACTIVA" at all, for five
  cases.
- `confirmed: true` is set only after a successful status read, in the real implementation, or by
  the dev fake backend behind `USE_FAKE_VERIFICATION_BACKEND`.

## No full document number, no facial image (FR-002, FR-018, SC-007)

- There is no `documentNumber` in the trips feature or the summary path.
- `documentLast4` is accepted only as exactly four digits (contract case 5).
- There is no `Image`, `NetworkImage`, `AssetImage` or `CircleAvatar` in the trips, Perfil or shell
  code. The avatar is `InitialsAvatar`. The widget test asserts that no `Image` is in the tree.

## The trip action never produces a pass (FR-009)

- `TripsHomeTarget.startTrip` pushes `AppRoutes.tripVerification`, the 013 placeholder. It shows
  no credential or pass and offers only "Volver".
- The action is enabled only for a confirmed active credential, a flight that is not cancelled,
  and the 24-hour window. The ViewModel tests cover every row of the table in precedence order.

## No travel data in events (FR-016, SC-010)

- `trips_analytics_payload_test.dart` asserts that every payload value is a bool, an int, or a
  `TripStatus` name, and never a flight number, an IATA code or a date.

## Open items for the user

- **Repeat use across flights** is measured by a count, `completedTripsLast90Days`, not by a
  per-passenger cohort. A cohort needs a stable anonymous identifier, and storing one needs a
  constitution amendment (research.md §9).
- **The backend** must add `holderName`, `documentLast4` and `suspended` to the status endpoint,
  and provide `GET /v1/trips`, before a release build.
