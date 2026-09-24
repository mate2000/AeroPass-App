# Data Model: Backend Integration (015)

The wire shapes are in [contracts/backend-api.md](./contracts/backend-api.md). This file covers the
types the app owns. Every type is a `freezed` sealed class or value type, and the DTOs are
`json_serializable`.

## Wire DTOs (`lib/data/models/backend/`)

The DTO names match the backend's schema names, so a contract diff is easy to read. Each DTO
parses with `checked: true` and `disallowUnrecognizedKeys: false`: new backend fields are
tolerated, and missing or renamed ones fail.

| DTO | Fields | Notes |
|---|---|---|
| `PasajeroDto` | `id`, `nombreCompleto`, `tipoDocumento`, `numeroDocumentoEnmascarado`, `fechaVencimiento`, `estado`, `intentosFallidos`, `identidadId?` | The enums are `@JsonEnum`, and an unknown value fails the parse |
| `ResultadoVerificacionDto` | `intentoId`, `resultado`, `motivoFallo?`, `scoreLiveness?`, `scoreComparacion?`, `estadoPasajero`, `intentosRestantes`, `identidadId?`, `reintentarEnSegundos?` | The scores exist only on the DTO, and the mapper drops them |
| `PaseDto` | `credencialId`, `token`, `codigoVuelo`, `permisos`, `estado`, `emitidaAt`, `expiraAt`, `renovarEnSegundos` | |
| `DetallePaseDto` | `credencialId`, `codigoVuelo`, `estado`, `emitidaAt`, `expiraAt`, `historial: List<TransicionDto>` | |
| `ErrorDto` | `codigo`, `detalles?` | `mensaje` is **not declared**, so it is ignored on parse (FR-007) |

## Domain types (`lib/domain/entities/`)

### `BackendError`

This type is new. It replaces a bare `DioException` at every repository boundary.

- `code`: `BackendErrorCode` has 14 values plus `unknown`:
  - `noAutenticado`
  - `datosInvalidos`
  - `documentoVencido`
  - `documentoYaRegistrado`
  - `cuentaYaRegistrada`
  - `pasajeroNoRegistrado`
  - `estadoNoPermiteVerificacion`
  - `imagenDemasiadoGrande`
  - `formatoNoAdmitido`
  - `almacenamientoNoDisponible`
  - `identidadNoActiva`
  - `limiteEmisionExcedido`
  - `credencialNoEncontrada`
- `status`: `int`.
- `retryAfter`: `Duration?`.
- `fields`: `List<String>`.

A transport failure stays `TransportFailure`, from 011.

### `PassengerRecord`

- `passengerId`
- `documentType`: `DocumentType`, one of `cc`, `ce` or `pasaporte`.
- `holderName`
- `maskedNumber`: the backend's string, verbatim.
- `documentExpiry`
- `state`: `PassengerState`, one of `pendingVerification`, `verified` or `manualReview`.
- `failedAttempts`
- `identityId?`

Persisted: `holderName` and `maskedNumber` only, as the display subset (Principle I).

### `RegistrationForm`

This is 004's typed input, held in memory.

- `fullName`
- `documentType`
- `number`: raw input, normalized with `normalizedNumber`.
- `expiry`: `DateTime?`.

`validate(today)` returns `Set<RegistrationField>`, following the rules in backend-api.md. The form
is cleared after a `Registered` result.

### `RegistrationOutcome`

This type is sealed. Its variants:

- `Registered(PassengerRecord, created)`
- `InvalidFields(Set<RegistrationField>)`
- `DocumentExpired`
- `AccountHasOtherDocument`
- `DocumentOwnedElsewhere`
- `RecaptureDocument`
- `ServiceBusy(Duration?)`
- `AuthFailure`

### `VerificationResult`

This type is sealed, and has no score fields. Its variants:

- `Verified(identityId?)`
- `Failed(reason, remaining, state)`:
  - `reason` is a `FailureReason`, either `match` or `generic`;
  - `LIVENESS` and a null reason both map to `generic`, so the liveness signal is erased at the
    boundary.
- `Inconclusive(retryAfter)`
- `NeedsReview`
- `StateChanged`
- `RecaptureSelfie`
- `AuthFailure`

The mapper applies outcome-mapping.md's ordering, so `NeedsReview` wins over a counter.

### `VerificationSubmission` (app layer, in memory)

State machine: `idle → inFlight → done(VerificationResult) | failed(error) → idle`.

- `submit(Uint8List jpeg)` is only legal from `idle`.
- The bytes are released when the state leaves `inFlight`.
- `SubmissionBackedJobRepository.getStatus()` maps `inFlight` → processing, and `done` → 007's
  terminal status.

### `FlightCode`

A value type. `FlightCode.parse(String)` returns `Result<FlightCode>`. It trims, upper-cases and
removes internal whitespace, then matches `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$`. It is held in memory
only.

### `Pass` (014's entity, changed)

| Field | Before | After |
|---|---|---|
| `passId` | kept | kept |
| `tripId` | present | removed |
| `flightCode` | — | added (`FlightCode`) |
| `token` | — | added (`String`) |
| `issuedAt` | — | added (server time) |
| `validUntil` | — | now server `expira_at` |
| `renewAfter` | — | added (`Duration`) |
| `permissions` | — | added (`Set<PassPermission>`, `boarding` only today) |
| `rotationSeconds` | present | removed |
| `nextCheckpoint` | present | removed |

- `PassState` gains `boarded`, from `CONSUMIDA`. Its `revoked` and `expired` values keep their
  meaning.
- `serverOffset = issuedAt − receivedAt`, and it feeds `ClockTrustMonitor`.

### `SessionState` (auth)

A sealed type with three variants: `signedIn`, `establishing` and `failed(AuthFailureKind)`.
`SessionTokenProvider.token()` returns `Result<String>`.

## Persisted state after this feature

Every entry is in secure storage:

| Key | Allowlist basis |
|---|---|
| credential display subset (name, masked number) | Principle I |
| consent record (version, timestamp) | Principle I |
| capture-attempt counters (003) | Principle I |
| Clerk client session | **A3 of the amendment proposal**. Not written until A3 is ratified, so staging and prod need ratification before a signed-in build |
| dev test id | dev flavor only; `assertReleaseSafe` refuses it in release |

Nothing else is persisted:

- no flight code;
- no pass or token;
- no image;
- no full document number;
- no score.
