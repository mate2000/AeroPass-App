# Contract: the pass screen (FR-001, FR-003, FR-008–FR-013, FR-016, FR-020, FR-022)

## Layout (the reference, as amended)

- **Top bar**: "‹ Atrás", which pops to Mis viajes and exits pass mode, and "Ayuda", which pushes
  help.
- **Header**: the holder name from the credential summary. The line "AV 9201 · BOG → MDE · Hoy
  14:35" in the airport's clock, using 012's formatter. The chip "Asiento 22A", only when a seat is
  known.
- **Stepper**: "Seguridad" and "Embarque". Done steps are checked only from `validated`. The current
  step is `nextCheckpoint`.
- **Pass**: the QR with the AeroPass mark at its centre, and a progress arc for the window's
  remaining time.
- **Countdown**: "Se actualiza en 00:26", as text with `liveRegion` off. It is announced once per
  rotation as "Código actualizado".
- **Footer**: "Presenta este código en el lector de seguridad" or "…de embarque", following
  `nextCheckpoint`.
- **Checkpoint line**: "Si tienes problemas, puedes usar el control habitual con tu documento."
  It is shown in every state (FR-013).
- **Dev control**: "Simular expirado", only when `devPassControls` (release-gate.md).

## Unavailable states

| Reason | Message | Action |
|---|---|---|
| expired | "Este código expiró" | "Solicitar nuevo código" |
| revoked / consentWithdrawn | "Tu identidad ya no está activa" | "Volver a Mis viajes" |
| flightCancelled / flightChanged | "Tu vuelo cambió" or "Tu vuelo fue cancelado" | "Volver a Mis viajes" |
| untrustedClock | "La hora de tu teléfono no coincide" plus "Activa la hora automática" | "Reintentar" |
| compromisedDevice | "No podemos mostrar tu pase en este dispositivo" | "Hablar con un agente" (010) |
| issuanceFailed | "No pudimos emitir tu código" | "Reintentar" |
| offlineWithoutPass | "Necesitas conexión para obtener tu código" | "Reintentar" |

No code is ever rendered in an unavailable state.

## Mis viajes change (012, FR-022)

The ViewModel asks `PassRepository.activePassFor(nextTrip.id)`. When a pass is active, the action is
"Ver pase", which opens `/trip/pass` directly, with no window, credential-confirmation or network
requirement. The pass screen still checks its own state. Otherwise, the 012 rules apply.

## Test-first cases

**ViewModel**:

- rotation at window boundaries, with `pass_rotated`;
- the countdown recomputed after a simulated pause;
- the stepper advancing only on status;
- the boarded state and `forget`;
- every unavailable reason;
- the clock drift (30 s) and jump detection;
- the compromised device never calling `issue`;
- pass-mode enter and exit rules;
- no payload in any event.

**Widget**:

- the header, chip and stepper, with no "Sala";
- the footer per checkpoint;
- no QR in unavailable or boarded states;
- the checkpoint line always present;
- no "Simular expirado" with the flag off;
- goldens for showing, expired, boarded and 2× text.

**Router**:

- "Continuar a tu pase" from the 013 placeholder;
- "Ver pase" from Mis viajes.
