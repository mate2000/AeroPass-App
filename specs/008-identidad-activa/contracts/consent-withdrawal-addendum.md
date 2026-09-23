# Addendum: consent withdrawal deletes the cached credential (change to 002)

Per research.md §6. Changes `ConsentRepositoryImpl.withdraw()` from specification 002.

## Why

Constitution Principle I: "Revoking MUST immediately invalidate the local credential and any
displayed pass." Before this feature, nothing wrote a credential, so withdrawal had nothing to
delete. This feature adds the writer; without this change a withdrawn passenger's relaunch would
still reach trips on the strength of the cached token.

## Change

- `CredentialService` gains `clearCachedCredential()`, deleting `aeropass.credential.token` and
  `aeropass.credential.valid_until`.
- `ConsentRepositoryImpl` receives `CredentialService` by constructor injection.
- In `withdraw()`, the local effect becomes: write the `withdrawalPending` record, then clear the
  cached credential. Both happen before backend delivery is attempted, so SC-005's "local effect
  with no network dependency" still holds.
- If clearing the credential throws, `withdraw()` returns `Result.error`. A withdrawal that leaves
  a usable credential behind is not a successful withdrawal.
- `WithdrawalViewModel` also clears `ActivatedCredentialHandoff`.

## Regression tests (added to 002's existing suites)

1. After `withdraw()` succeeds, `CredentialService.readCachedCredential()` returns `null`.
2. After `withdraw()`, the router sends a relaunch to welcome, not trips.
3. Offline `withdraw()` still clears the credential locally.
4. A failure clearing the credential makes `withdraw()` return `Result.error`.
5. All of 002's existing withdrawal tests still pass unchanged.
