# Contract: AeroPass backend, as the app consumes it

**Source of truth**: the backend source, `src/aeropass/api/schemas.py`, `api/routers/*` and
`domain/errors.py`, as of 2026-09-23. Guide v2 is secondary. The contract tests
(`test/contract/backend_api_contract_test.dart`) replay the JSON fixtures in
`test/fixtures/backend/`, copied from the source schemas. They fail on any renamed field or changed
enum value (FR-019).

## Transport

- **Base URL**: `API_BASE_URL`, per flavor (research.md §3).
- **TLS**: trust-anchor pinning (research.md §4). dev's local HTTP is behind
  `ALLOW_INSECURE_LOCAL_BACKEND`.
- **Auth**: `Authorization: Bearer <token>` on every `/v1/*` call. The token comes from
  `SessionTokenProvider.token()` immediately before the request.
- **401**: invalidates the session, re-establishes it silently, and retries **once**. A second 401
  → `AuthFailure` → the "we could not connect your session" state.
- **Timeouts**:

  | Call | Connect | Send | Receive |
  |---|---|---|---|
  | Default | 5 s | 10 s | 5 s |
  | Both multipart uploads | 5 s | 30 s | — |
  | Verification | — | — | 35 s |

- **Logging**: no logging interceptor (research.md §13).

## Endpoints

### `POST /v1/identity`: register

Multipart request. Every part is required (V-01):

| Part | Value | Rule applied on the device first |
|---|---|---|
| `nombre_completo` | text | 2–200 characters after collapsing whitespace |
| `tipo_documento` | `CC` \| `CE` \| `PASAPORTE` | a closed enum |
| `numero_documento` | text | 4–20 of `[A-Z0-9]` after removing separators and upper-casing |
| `fecha_vencimiento` | `YYYY-MM-DD` | today or later, in the device's date. The server decides |
| `foto_documento` | file `documento.jpg`, content type `image/jpeg` | ≤ 4 MB. The bytes begin `FF D8 FF` |

| Status | Body | App outcome |
|---|---|---|
| 201 | `PasajeroResponse` | `Registered(created: true)` |
| 200 | `PasajeroResponse` | `Registered(created: false)`. The first photo is kept (V-03) |
| 409 `CUENTA_YA_REGISTRADA` | Error | `AccountHasOtherDocument` |
| 409 `DOCUMENTO_YA_REGISTRADO` | Error | `DocumentOwnedElsewhere` → agent path (FR-001a) |
| 413 `IMAGEN_DEMASIADO_GRANDE`, 415 `FORMATO_NO_ADMITIDO` | Error | `RecaptureDocument` |
| 422 `DATOS_INVALIDOS` | Error with `detalles.campos` | `InvalidFields(campos)` |
| 422 `DOCUMENTO_VENCIDO` | Error | `DocumentExpired` |
| 503 `ALMACENAMIENTO_NO_DISPONIBLE` | Error with `Retry-After` | `ServiceBusy(retryAfter)` → 011 |
| 401 | Error | see Transport |

`PasajeroResponse` has these keys, all required unless marked nullable:

- `id` (uuid)
- `nombre_completo`
- `tipo_documento`
- `numero_documento_enmascarado`
- `fecha_vencimiento` (date)
- `estado` (`PENDIENTE_VERIFICACION` \| `VERIFICADO` \| `REQUIERE_REVISION_MANUAL`)
- `intentos_fallidos` (int, 0–3)
- `identidad_id` (uuid, nullable)

### `GET /v1/identity/me`: current passenger and resume state

- **200**: `PasajeroResponse`.
- **404 `PASAJERO_NO_REGISTRADO`**: → `NotRegistered`.
- **Other statuses**: as in Transport.

How the app routes on the result is in research.md §9.

### `POST /v1/biometrics/verifications`: verify the selfie

Multipart, with one part: `selfie`, file `selfie.jpg`, content type `image/jpeg`, ≤ 4 MB.

| Status | App outcome |
|---|---|
| 200 `ResultadoVerificacionResponse` | see outcome-mapping.md |
| 404 `PASAJERO_NO_REGISTRADO` | `NotRegistered` → re-read `/me` |
| 409 `ESTADO_NO_PERMITE_VERIFICACION` | `StateChanged` → re-read `/me` and route |
| 413, 415 | `RecaptureSelfie` |
| 422 `DATOS_INVALIDOS` | `RecaptureSelfie`. The only field is `selfie` |

`ResultadoVerificacionResponse` fields, all required unless marked nullable:

- `intento_id` (uuid)
- `resultado` (`EXITOSO` \| `FALLIDO` \| `NO_CONCLUYENTE`)
- `motivo_fallo` (`LIVENESS` \| `COMPARACION`, nullable)
- `score_liveness`, `score_comparacion` (float, nullable). **Parsed only to be discarded.** The
  domain type has no score field.
- `estado_pasajero`
- `intentos_restantes` (int)
- `identidad_id` (uuid, nullable)
- `reintentar_en_segundos` (int, nullable)

### `POST /v1/passes`: issue or renew

JSON body: `{"codigo_vuelo": "<normalized>"}`. The code matches `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$`
and is at most 16 characters.

| Status | App outcome |
|---|---|
| 201 `PaseResponse` | `Issued(pass)` |
| 403 `IDENTIDAD_NO_ACTIVA` | `IdentityNotActive` → re-read `/me` and route. It is also returned when the passenger is not registered |
| 403 `DOCUMENTO_VENCIDO` | `DocumentExpired` → agent path, no retry |
| 422 `DATOS_INVALIDOS` (`campos: ["codigo_vuelo"]`) | `InvalidFlightCode` |
| 429 `LIMITE_EMISION_EXCEDIDO` | `RateLimited(retryAfter)` |
| 503 `ALMACENAMIENTO_NO_DISPONIBLE` | `ServiceBusy(retryAfter)`. `Retry-After` is 1 here |

`PaseResponse` fields:

- `credencial_id` (uuid)
- `token` (a compact JWS, rendered as the QR)
- `codigo_vuelo`
- `permisos` (`string[]`)
- `estado`
- `emitida_at`, `expira_at` (ISO-8601 with offset)
- `renovar_en_segundos` (int, currently 40)

Renewal is the same call. The backend refreshes or revokes the previous credential, and always
returns a **new** `credencial_id`.

### `GET /v1/passes/{credencial_id}`: pass detail

- **200**: `DetallePaseResponse`. Its fields are `credencial_id`, `codigo_vuelo`, `estado`
  (`EMITIDA` \| `ACTIVA` \| `CONSUMIDA` \| `EXPIRADA` \| `REVOCADA`), `emitida_at`, `expira_at`
  and `historial[]`.
- **404 `CREDENCIAL_NO_ENCONTRADA`**: → `PassGone`.
- There is no token here. `historial` is parsed for the contract test and not used.

### `GET /.well-known/jwks.json`

Not called by the app.

## Error body

```json
{"codigo": "<CODE>", "mensaje": "<text, never parsed>", "detalles": {"campos": ["..."]}}
```

- `detalles` is optional.
- `Retry-After` is an integer number of seconds. CORS exposes it; that is irrelevant on mobile.
- A body that does not parse, or a status outside the tables, maps to `BackendError(unknown)` and
  the generic path.

## Call order

Derived from the routers, because `e2e_flow.py` does not exist (research.md §1):

1. On launch: the session (silent), then `GET /v1/identity/me`.
2. 404 → consent (local) → 003 capture (local) → 004 typed fields → `POST /v1/identity`.
3. `PENDIENTE_VERIFICACION` → 005 → 006 → `POST /v1/biometrics/verifications` → 007 routes.
4. `VERIFICADO` → 008 → 012 flight code → `POST /v1/passes`. Then renew every
   `renovar_en_segundos`, and poll `GET /v1/passes/{id}` every 5 s while 014 is visible.
