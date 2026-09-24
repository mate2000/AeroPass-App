# Contract: backend outcomes → app states → passenger wording

This is the single table that SC-002, SC-004 and SC-007 are tested against.

- **Rule 1**: the "Passenger sees" column is the only text that may appear. No `codigo`, enum name,
  score or `mensaje` reaches a widget (FR-007).
- **Rule 2**: `test/unit/outcome_wording_test.dart` renders every row and asserts that none of the
  backend identifiers appear.

## Verification (`ResultadoVerificacionResponse`)

Rows are evaluated top to bottom, and the first match wins. The state is checked before the counter
(spec edge case).

| # | Condition | 007 terminal outcome | Screen | Passenger sees |
|---|---|---|---|---|
| 1 | `estado_pasajero = REQUIERE_REVISION_MANUAL` | `escalated` | 010 | 010's copy: "Un agente puede ayudarte" and the conventional-lane line |
| 2 | `resultado = EXITOSO` | `activated` | 008 | "Registro completado" while the mock is declared (FR-020); 008's normal copy otherwise |
| 3 | `resultado = NO_CONCLUYENTE` | `serviceFailure(retryAfter: reintentar_en_segundos)` | 011 | 011's service copy. No attempt is consumed, and none is shown as consumed (FR-005) |
| 4 | `FALLIDO`, `intentos_restantes = 0` | `escalated` | 010 | as row 1 |
| 5 | `FALLIDO`, `motivo_fallo = COMPARACION` | `retry(guidance: match, remaining: n)` | 009 | the match guidance ("Quítate gafas o gorra…"), then "Te quedan {n} intentos" |
| 6 | `FALLIDO`, `motivo_fallo = LIVENESS` | `retry(guidance: generic, remaining: n)` | 009 | the **generic** copy, identical to row 7 (FR-006) |
| 7 | `FALLIDO`, `motivo_fallo = null` | `retry(guidance: generic, remaining: n)` | 009 | the generic copy |

- **`remaining`** is always `intentos_restantes`. 009's view reads it from the outcome, and the
  release wiring has no local verification-attempt counter (FR-008).
- **`identidad_id = null` on `EXITOSO`**: accepted. 008 re-reads `/me` before showing the result
  (research.md §9).

## Registration

| Outcome | Screen | Passenger sees |
|---|---|---|
| `Registered` | continue to 005 | the masked number, `numero_documento_enmascarado`, verbatim |
| `InvalidFields(campos)` | 004 | each named field marked: "Revisa este dato" |
| `DocumentExpired` | 004 | "Tu documento está vencido. Necesitas un documento vigente para continuar." Agent path offered |
| `AccountHasOtherDocument` | 004 | "Esta cuenta ya tiene otro documento registrado." Agent path offered |
| `DocumentOwnedElsewhere` | 010 | 010's copy. This is not shown as the passenger's error (FR-001a) |
| `RecaptureDocument` | 003 | "Toma la foto de nuevo" |
| `ServiceBusy(retryAfter)` | 011 | 011's service copy. The countdown uses `retryAfter` |

## Pass

| Outcome | Screen state | Passenger sees |
|---|---|---|
| `Issued` | `showing` | the QR code, with its countdown to the next renewal |
| renewal failed, before `expira_at` | `showing (renewal pending)` | the QR code, with "Actualizando código…" |
| renewal failed, at or after `expira_at` | `unavailable(expired)` | "Este código ya no sirve. Pasa por el carril convencional." No QR code (FR-012, SC-006) |
| `RateLimited`, `ServiceBusy` | as above, and the next attempt waits for `Retry-After` | as above (FR-014) |
| detail `CONSUMIDA` | `boarded` | "Abordaje confirmado · Buen viaje". Renewal stops (FR-015b) |
| detail `EXPIRADA`, `REVOCADA`, or `PassGone` for the current id | `unavailable(expired)` | as expired |
| `IdentityNotActive` | re-read `/me` and route | whatever the route shows |
| `DocumentExpired` (403) | `unavailable(documentExpired)` | "Tu documento está vencido." Agent path offered. No retry (FR-015) |
| `InvalidFlightCode` | 012 entry | "Revisa el código de vuelo (ej. AV9201)" |

## Session

| Outcome | Passenger sees |
|---|---|
| `AuthFailure` after the silent retry | "No pudimos conectar tu sesión. Revisa tu conexión e inténtalo de nuevo." Retry action. Not 011's service copy |
