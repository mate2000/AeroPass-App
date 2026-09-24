# Data Model: Observabilidad con Sentry (App móvil)

**Feature**: 015 · Referencias: [spec.md](spec.md) Key Entities · [research.md](research.md)

**Nada nuevo se guarda en el dispositivo.** Todo lo de esta feature vive en memoria o se envía a Sentry. La lista de datos persistidos del Principio I no cambia.

Tipos inmutables y generados donde aplica (Principio IX).

## Entidades en la app (memoria)

### `CurrentEnrollmentAttempt` (capa de datos)
Valor vigente del intento de registro para etiquetar la telemetría (research §10).

| Campo | Tipo | Regla |
|---|---|---|
| `attemptId` | `EnrollmentAttemptId?` | `null` antes de confirmar el consentimiento o después de revocarlo |

Transiciones: `null` → valor (al arrancar, si existe registro de consentimiento; o cuando `recordConsent` devuelve `Ok`) → `null` (al revocar el consentimiento). Nunca se guarda por su cuenta: su origen es el `ConsentRecord` ya persistido.

### `EnrollmentTiming` (capa de datos, dentro del destino de Sentry)
Hora de inicio en memoria para calcular la duración (research §3).

| Campo | Tipo | Regla |
|---|---|---|
| `attemptId` | `EnrollmentAttemptId` | el intento al que pertenece |
| `startedAt` | `DateTime` (del `Clock` inyectado) | se fija en el **primer** `capture_step_entered` del intento en este arranque; los siguientes no lo cambian |

Se descarta al emitir la duración o al terminar el proceso. Un intento retomado en otro arranque no tiene `EnrollmentTiming` y no emite duración.

### `AnalyticsSink` (puerto de la capa de datos)
Destino de un evento ya construido por el emisor (research §11).

| Operación | Entrada | Salida |
|---|---|---|
| `record` | `eventName` (String), `payload` (mapa de claves del contrato → enum/int/bool/String), `sessionId` | nada; nunca lanza ni espera la red |

Implementaciones: `DeveloperLogAnalyticsSink` (el log local actual) y `SentryLogAnalyticsSink`.

### `TelemetryConfig` (extiende `SentryConfig`)
Valores leídos de `env/*.env` (research §7), con constantes con nombre como valor por defecto.

| Campo | Variable | Valor por defecto (prod) |
|---|---|---|
| `tracesSampleRate` | `SENTRY_TRACES_SAMPLE_RATE` | 0.2 |
| `profilesSampleRate` | `SENTRY_PROFILES_SAMPLE_RATE` | 0.2 |
| `replaySessionSampleRate` | `SENTRY_REPLAY_SESSION_SAMPLE_RATE` | 0.1 |
| `replayOnErrorSampleRate` | `SENTRY_REPLAY_ON_ERROR_SAMPLE_RATE` | 1.0 |

Regla: cada valor en [0, 1]; un valor fuera de rango hace fallar el arranque en compilaciones de desarrollo y se reemplaza por el valor por defecto en release.

## Entidades en Sentry (lo que se envía)

| Entidad | Forma en Sentry | Definición |
|---|---|---|
| Evento de negocio | Log `info` | [contracts/telemetry-events.md](contracts/telemetry-events.md) §1 |
| Intento de registro | Valor del atributo `aeropass.enrollment_attempt_id` | se cuenta con `count_unique` |
| Duración del registro | Métrica de distribución `enrollment.duration` | [contracts/telemetry-events.md](contracts/telemetry-events.md) §2 |
| Evento de error | Error/crash del SDK, pasado por el filtro | [contracts/privacy-filter.md](contracts/privacy-filter.md) |
| Traza de rendimiento | Transacción de navegación por nombre de ruta + TTID/TTFD | research §8 |
| Regla de alerta y widget | Configuración manual en la UI | [contracts/dashboard-and-alerts.md](contracts/dashboard-and-alerts.md) |

## Estados de un intento de registro (derivados en Sentry, no en la app)

```
empezado (capture_step_entered) ──► completado (credential_activated_shown)
        │
        └── sin completar 15 min después del inicio ──► abandonado
                                   │
                                   └── completa más tarde (retomado) ──► completado
```

`completado` y `abandonado` no los calcula la app: salen de la consulta `count_unique` en Sentry. El plazo de 15 minutos aplica al análisis; las alertas evalúan la hora completa sin plazo ni volumen mínimo (desviación D1 aceptada, [contracts/dashboard-and-alerts.md](contracts/dashboard-and-alerts.md)).
