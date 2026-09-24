# Verification Record: AeroPass backend contract (2026-09-23)

This is the input to specification 015, kept as the audit trail. The specification binds behavior;
this file records how the contract was established.

The contract was checked against these sources:

- the deployed service at `https://aeropass-lac.vercel.app`, meaning its `/openapi.json` and
  `/.well-known/jwks.json`;
- the backend source at `AirPass/Aeropass/src/aeropass`.

The guide versions checked against them:

- guide v1, superseded;
- guide v2 (PDF, 17:04), accurate except for R-01;
- guide v3 (17:18), which adds section 10 on where data lives.

## Discrepancy register: guide v1 against reality (all resolved in v2)

| # | Guide v1 says | Reality | Impact |
|---|---|---|---|
| D-01 | `POST /v1/identity` takes JSON | multipart/form-data, with Form fields and a `foto_documento` file | Every request built from the guide fails |
| D-02 | Field `fecha_nacimiento` | The field is `fecha_vencimiento`, the document expiry. No birth date exists anywhere | Wrong field, and data the backend never asked for |
| D-03 | No document photo | `foto_documento` is stored privately as the biometric reference | Spec 003's capture has a destination the guide hides |
| D-04 | `tipo_documento: "cedula"` | `CC`, `CE` or `PASAPORTE` | 422 on every registration |
| D-05 | `{pasajero_id, estado:"registrado"}` | `id`, `nombre_completo`, `tipo_documento`, `numero_documento_enmascarado`, `fecha_vencimiento`, `estado`, `intentos_fallidos`, `identidad_id` | Wrong keys |
| D-06 | `estado: "registrado"` | `PENDIENTE_VERIFICACION`, `VERIFICADO` or `REQUIERE_REVISION_MANUAL` | The value is not in the enum |
| D-07 | Re-registration is always 409 | Identical resubmission is 200. A different document is 409 `CUENTA_YA_REGISTRADA`. Another account's document is 409 `DOCUMENTO_YA_REGISTRADO` | Resume logic breaks |
| D-08 | Biometrics returns 201 | 200 | Status branching fails |
| D-09 | `{verificacion_id, liveness_score, match_score, resultado}` | `intento_id`, `resultado`, `motivo_fallo`, `score_liveness`, `score_comparacion`, `estado_pasajero`, `intentos_restantes`, `identidad_id`, `reintentar_en_segundos` | Every field name differs |
| D-10 | Two outcomes | `EXITOSO`, `FALLIDO` or `NO_CONCLUYENTE` | No path for the degraded case (011) |
| D-11 | No failure reason | `LIVENESS` or `COMPARACION` | Needed to split "coach the passenger" from "say nothing" |
| D-12 | No attempt counter | `intentos_restantes` and `intentos_fallidos` | The counter is server-owned |
| D-13 | `POST /v1/passes` takes no body | It requires `{"codigo_vuelo": "<=16 chars>"}` | 422 on every issuance |
| D-14 | `{credencial_id, qr_payload, expira_en}` | `credencial_id`, `token`, `codigo_vuelo`, `permisos[]`, `estado`, `emitida_at`, `expira_at`, `renovar_en_segundos` | `qr_payload` does not exist |
| D-15 | Expiry implies hours | `QR_TTL_SECONDS` = 45, within 30–60 enforced by a database CHECK. Renewal is at the TTL minus 5 | DEC-01 |
| D-16 | `vigente`, `expirado` or `revocado` | `EMITIDA`, `ACTIVA`, `CONSUMIDA`, `EXPIRADA` or `REVOCADA` | None of the guide's values exist |
| D-17 | The detail has 3 fields | It adds `historial[]` | Audit trail |
| D-18 | Errors 401, 404, 409, 422, 500 | It adds 403 `IDENTIDAD_NO_ACTIVA` and `DOCUMENTO_VENCIDO`, 409 `ESTADO_NO_PERMITE_VERIFICACION`, 413, 415, 429 and 503, some with `Retry-After` | Six unmentioned classes |
| D-19 | Error body `{codigo, mensaje}` | It adds optional `detalles`, for example `{"campos": [...]}` | Field-level errors are available |
| D-20 | "Mock mode" | The mock reads a marker in the bytes. An unmarked image scores 0.95 and 0.93 and is approved | R-01 |

## Facts from v2 that close earlier clarifications

- **Spec 009 FR-009**: the attempt limit is 3 (`intentos_fallidos` CHECK 0..3). The third failure
  sets `REQUIERE_REVISION_MANUAL`.
- **Spec 003**: the accepted documents are CC, CE and PASAPORTE.
- **Spec 004 FR-008**: `fecha_vencimiento` must be today or later.
- **Specs 001 FR-008 and 007 FR-010**: `GET /v1/identity/me` gives the resume state in one call.
- **Tokens**: Clerk tokens last about 60 s. Fetch one per call and never cache it.
- **Issuance**: limited to 30 per 60 s per passenger. Renewal every 40 s is well inside that.
- **Call order**: `src/aeropass/tools/e2e_flow.py` walks the whole flow against production. Mirror
  its order.

## Risks the guide does not mention

- **R-01**: the deployed service approves any selfie. It will issue a signed credential to anyone
  who uploads any photo. That is acceptable for an integration milestone and disqualifying for
  anything a passenger or an airport sees.
- **R-02**: there is no consent endpoint (DEC-02).
- **R-03**: there are no trips or flights. `FlightCatalog` checks the format only (DEC-03).
- **R-04**: the app has no checkpoint validation feed. F-01 shows that `CONSUMIDA` is nevertheless
  reachable.
- **R-05**: the document photo is persisted server-side at `documentos/{pasajero_id}/rostro-*`.
- **R-06**: `/openapi.json` is public.
- **R-07**: a `.pgdata/` directory is in the backend working tree. Confirm that git ignores it.
- **R-08**: `CLERK_AUTHORIZED_PARTIES` is empty, so `azp` is unchecked. This is low severity for
  mobile.

## Guide v3, section 10: where data lives

| Store | Contents |
|---|---|
| Neon Postgres | All business data, the source of truth |
| Vercel Blob (private) | `documentos/{pasajero_id}/rostro-{suffix}` and `selfies/{pasajero_id}/{intento_id}-{suffix}` |
| Upstash Redis | `qr:{jti}`, `rl:passes:{pasajero_id}`, `cb:{name}` |
| Upstash QStash | The outbox delivery queue |

- **F-01: the pass is single-use.** `qr:{jti}` moves from `ACTIVA` to `CONSUMIDA` atomically, and
  the TTL is untouched, so consumed and expired are told apart. Revoking a pass deletes the key.
  `CONSUMIDA` is reachable in production and means success.
- **F-02: rate limiting fails open** when Redis is down, so a 429 is always a real limit.
- **F-03: retention has three figures and no code.** No deletion job exists, and
  `imagen_eliminada_at` is never written. The three figures:

  | Source | Retention | Status |
  |---|---|---|
  | OKR A2.6 and the app constitution | ≤ 30 days after the last flight | Declared to the airport |
  | Screen 02, the consent text | 5 years, or until the passenger asks for deletion | Told to the passenger |
  | Backend spec (guide v3) | 90 days after revocation or the last failed attempt | Not implemented |

  This is the highest-severity open item in the product. Its owner is not the mobile team.
- **F-04: local fake mode does not affect the app.** `Bearer test:<user_id>` works against a local
  backend.

## Second check (this specification, V-01 to V-08)

These are listed in spec.md under "Verification Summary", with their source locations.
