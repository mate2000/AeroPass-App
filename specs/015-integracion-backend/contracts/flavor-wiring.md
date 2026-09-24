# Contract: flavors, build flags and port wiring

## Env files

Read with `--dart-define-from-file`.

| Key | dev | staging | prod | Release check |
|---|---|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:8000` | `https://aeropass-lac.vercel.app` | `https://aeropass-lac.vercel.app` | prod must be `https://` and must not contain `.example` |
| `AUTH_MODE` | `test` | `clerk` | `clerk` | prod must be `clerk` |
| `CLERK_PUBLISHABLE_KEY` | — | `pk_…` | `pk_…` | required when `AUTH_MODE=clerk` |
| `ALLOW_INSECURE_LOCAL_BACKEND` | true | — | — | forbidden in prod |
| `SYNTHETIC_CAPTURE` | true | true | — | forbidden in prod |
| `BIOMETRIC_PROVIDER_MOCK` | true | true | true | may be false only if `BIOMETRIC_PROVIDER_NAME` is set and is not `mock` |
| `USE_FAKE_CONSENT_BACKEND`, `USE_FAKE_VERIFICATION_BACKEND`, `DEV_PASS_CONTROLS` | optional | — | — | forbidden in prod, as today |

- **`tool/check_release_env.dart`** gains these rules. Its test covers each rule.
- **`HappyPathFlags.assertReleaseSafe`** adds `ALLOW_INSECURE_LOCAL_BACKEND`, `SYNTHETIC_CAPTURE`
  and `AUTH_MODE=test`.
- **`env/dev-offline.env`** is unchanged. It stays the no-backend demo, which uses the in-app fakes.

## Port wiring

"backend" means a new release implementation. "local" means a release implementation that makes no
network call. "dev-only" means the existing class, kept behind a happy-path flag or dev flavor
(spec Q3).

| Port | prod and staging | dev (local backend) | dev-offline |
|---|---|---|---|
| `SessionTokenProvider` (new) | `ClerkSessionTokenProvider` | `TestSessionTokenProvider` | none (fakes need no token) |
| `ConsentRepository` | `LocalConsentRepository` (local) | `LocalConsentRepository` | `DevConsentRepository` |
| `DocumentVerificationRepository` | `LocalDocumentCaptureRepository` (local) | same | `DevDocumentVerificationRepository` |
| `FieldReverificationRepository` | not wired; the entry point is hidden | not wired | dev fake |
| `IdentityRecordRepository` | `BackendIdentityRecordRepository` | same | dev fake |
| `LivenessVerificationRepository` | `LocalLivenessRepository` (local) | same | dev fake |
| `VerificationJobRepository` | `SubmissionBackedJobRepository` | same | `DevVerificationJobRepository` |
| `CredentialIssuanceRepository` | not wired; 008 re-reads `/me` | not wired | dev fake |
| `CredentialRepository`, `CredentialSummaryRepository` | `PassengerBackedCredentialRepository` | same | dev fakes |
| `EscalationRepository`, `AgentChatRepository` | not wired; 010 has no chat | not wired | dev fakes |
| `ServiceStatusRepository` | not wired; 011 has no card | not wired | dev fake |
| `TripRepository` | not wired; 012 shows flight-code entry | not wired | dev fake |
| `PassRepository` | `BackendPassRepository` | same | `DevPassRepository`, on the 40 s model |
| `PassCodeSource` | `IssuedTokenPassCodeSource` | same | `DevPassCodeSource` |
| Capture image source | camera | `SyntheticImageSource` | camera |

- **"Not wired"** means the ViewModel receives `null` for an optional dependency, and renders its
  release variant. The composition root never constructs a class that calls a nonexistent path.
- **The rule is enforced by a test** (`test/architecture/release_wiring_test.dart`). It builds the
  prod composition with a recording HTTP adapter, walks the router, and asserts that every
  requested path is one of the five in backend-api.md (FR-025).

## Classes deleted rather than kept

These target paths that exist nowhere, and their dev fakes do not use them:

- `DocumentVerificationService`, `FieldReverificationService`, `IdentityRecordService` (the old
  path);
- `LivenessVerificationService`, `VerificationJobService`, `CredentialIssuanceService`;
- `ConsentService`'s network methods;
- `EscalationService`, `AgentChatService`, `ServiceStatusService`, `TripService`;
- `PassService.code/status`, and `BackendPassCodeSource`;
- their `…RepositoryImpl` wrappers, and their contract tests.

The dev fakes and the ports stay, which satisfies Q3. The dev fakes implement the ports, not the
deleted services.
