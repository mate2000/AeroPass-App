# Contrato: telemetría del embudo enviada a Sentry

**Feature**: 015 · Referencias: [research.md](../research.md) §1–§3, §5, §10–§11 · FR-005, FR-006, FR-007, FR-008

Este contrato es la **lista blanca** que aplica `SentryPrivacyFilter` a logs y métricas (research §5). Un atributo que no esté aquí no llega a Sentry. Agregar un atributo requiere cambiar este archivo en el mismo PR y revisarlo contra el Principio VII.

## 1. Logs del embudo

Un log por cada llamada al `AnalyticsEmitter`, nivel `info`, mensaje = nombre del evento.

### Atributos de sobre (todos los logs del embudo)

| Atributo | Tipo | Origen | Cuándo |
|---|---|---|---|
| `aeropass.event` | string | nombre del evento (snake_case, igual que el log local actual) | siempre |
| `aeropass.session_id` | string | `AnalyticsSessionId` (por arranque, en memoria) | siempre |
| `aeropass.enrollment_attempt_id` | string | `CurrentEnrollmentAttempt` (research §10) | solo si hay un intento vigente (después de confirmar el consentimiento) |

Los atributos que el SDK agrega por su cuenta (`sentry.environment`, `sentry.release`, `sentry.sdk.*`, `os.*`, `device.*` sin identificadores) se conservan. Cualquier atributo de usuario (`user.*`) se elimina.

### Atributos de payload permitidos

Son exactamente las claves que ya emite `LoggingAnalyticsEmitter`, con prefijo `aeropass.`. Todas son enums (por nombre), enteros, booleanos o, en un caso, un identificador de versión de texto; ninguna es un dato personal.

| Atributo | Tipo | Eventos que lo usan (resumen) |
|---|---|---|
| `aeropass.variant` | string (enum) | `welcome_*` |
| `aeropass.reason` | string (enum) | `*_rejected`, `*_unavailable_shown`, `liveness_outcome`, `pass_expired`, … |
| `aeropass.has_prior_record` | bool | `consent_gate_shown` |
| `aeropass.text_version_id` | string | `consent_confirmed` (versión del texto legal, no del pasajero) |
| `aeropass.permanent` | bool | `capture_permission_denied_shown` |
| `aeropass.attempt_number` | int | `capture_attempted`, `liveness_attempt_count` |
| `aeropass.field` | string (enum `FieldKey`, nunca el valor) | `confirmation_field_*` |
| `aeropass.confirmed` | bool | `confirmation_field_reverified` |
| `aeropass.phase_index`, `aeropass.total_phases` | int | `liveness_phase_reached` |
| `aeropass.outcome` | string (enum) | `liveness_outcome` |
| `aeropass.kind` | string (enum) | `credential_issuance_outcome`, `verification_outcome`, `escalation_outcome` |
| `aeropass.elapsed_seconds` | int | `verification_outcome`, `escalation_outcome`, `technical_error_resolved` |
| `aeropass.stage`, `aeropass.status` | string (enum) | `verification_stage_reached`, `technical_error_shown`, `trip_displayed` |
| `aeropass.failure_class`, `aeropass.job_terminal` | string / bool | `technical_error_shown` |
| `aeropass.route`, `aeropass.state`, `aeropass.destination` | string (enum) | `credential_activated_route_taken`, `retry_guidance_*` |
| `aeropass.arrival`, `aeropass.channel` | string (enum) | `escalation_*` |
| `aeropass.module_available`, `aeropass.chat_available` | bool | `escalation_channels_offered` |
| `aeropass.document_scan`, `aeropass.selfie`, `aeropass.issuance`, `aeropass.credential_confirmed` | string (enum) / bool | eventos de 007–009 que ya los emiten |
| `aeropass.live`, `aeropass.within_window`, `aeropass.has_next_trip`, `aeropass.row_count` | bool / int | `trip_*`, `trips_*` |
| `aeropass.checkpoint`, `aeropass.offline_capable`, `aeropass.seconds_since_opened`, `aeropass.succeeded` | string (enum) / bool / int | `pass_*` |

La lista definitiva se genera en la implementación a partir de las claves de `LoggingAnalyticsEmitter` (una prueba compara ambas listas; ver quickstart §3). La conversión de camelCase a snake_case es mecánica y única.

### Prohibido siempre

Aunque alguien lo agregue al payload: nombre, número de documento, fecha de nacimiento, valores de campos editados, imágenes o frames, tokens de credencial, payload o contenido del QR, respuestas crudas del proveedor, IP, identificadores de dispositivo o de publicidad.

## 2. Métrica de duración del registro

| Métrica | Tipo | Unidad | Atributos permitidos | Cuándo se emite |
|---|---|---|---|---|
| `enrollment.duration` | distribution | millisecond | `aeropass.resumed` = `false` (siempre, deja explícito el alcance) | Al emitir `credential_activated_shown`, solo si el primer `capture_step_entered` de ese intento ocurrió en este mismo arranque (research §3) |

## 3. Eventos de error y alerta existentes (011)

Sin cambios de forma. El evento `verification_service_failure` con las etiquetas `failure_class` y `failure_stage` sigue igual; ahora pasa por el filtro general (research §5) en vez de `stripAlertEventPii`.

## 4. Garantías

- **Sin DSN**: no se envía nada a Sentry; los logs siguen en el log local (Historia 2, escenario 2).
- **Sin red**: el SDK encola y envía al recuperar la conexión; ninguna llamada del emisor espera la red (FR-012).
- **Orden y duplicados**: no se garantiza orden entre logs; las métricas de negocio no dependen del orden, solo de `count_unique` y de la distribución.

## 5. Diagnósticos operativos (`Diagnostics`)

Logs de diagnóstico del flujo técnico (spec 015-integracion-backend): cada llamada al backend, cada paso de la navegación de arranque, cada intento de selfie con su causa, la sesión de Clerk, el ciclo de vida de la app y los fallos inyectados (§6). Sirven para diagnosticar en producción lo que el embudo no muestra.

- **Forma**: nivel `info`, `warn` o `error`; mensaje = nombre del evento (`backend_http`, `selfie_verification`, `redirect_step`, `session_gate`, `fault_injected`, …); `aeropass.event` igual al mensaje.
- **Atributos**: todos bajo el prefijo **`aeropass.diag.`** (por ejemplo `aeropass.diag.path`, `aeropass.diag.status`, `aeropass.diag.code`, `aeropass.diag.ms`). El filtro admite el prefijo completo.
- **Qué contienen**: solo códigos y estados (enums del backend y de la app), métodos y rutas HTTP sin query, códigos de estado, tamaños en bytes y duraciones en ms.
- **Doble defensa**: `Diagnostics` redacta cada valor de texto antes de enviarlo (correos, JWT, `Bearer …` y secuencias de 6 o más dígitos) y corta los valores largos. Los números (tamaños, duraciones, estados) se envían tal cual.
- **Migas**: los mismos datos, redactados, como migas de categoría `diagnostics`.
- **Prohibido siempre**: lo mismo que §1 (nombre, número de documento, correo, códigos tecleados, tokens, cabeceras, cuerpos de petición o respuesta, imágenes). Un atributo nuevo en `aeropass.diag.*` se revisa en el PR contra esa lista.

## 6. Inyección de fallos (builds `chaos`)

Solo en builds con `CHAOS_TOOLS=true` (un release se niega a arrancar con esa bandera y `tool/check_release_env.dart` la rechaza).

- **`fault_injected`** (`warn`): un fallo inyectado en una petición. Atributos: `aeropass.diag.fault` (nombre del fallo: `latency`, `timeout`, `connectionLost`, `http500`, `http503Storage`, `http504`, `http401`, `http429`, o el fallo pedido al backend), `aeropass.diag.path`, `aeropass.diag.method`.
- **Fallos pedidos al backend**: header `X-AeroPass-Fault` (spec 003 del backend), más `X-AeroPass-Fault-Key` si el Preview tiene `FAULT_INJECTION_SECRET` (la app lo lee de `FAULT_INJECTION_KEY`). El backend responde `X-AeroPass-Fault-Applied` con los fallos que se dispararon.
- **Mientras haya un fallo activo**, todo log de `Diagnostics` lleva además `aeropass.diag.fault_injected = true` y `aeropass.diag.fault`, y los eventos de Sentry llevan la etiqueta `fault_injected`, para separar en los tableros lo inyectado de un incidente real.
