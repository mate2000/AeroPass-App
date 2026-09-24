# Contrato: dashboard y alertas del proyecto `aeropass-app`

**Feature**: 015 · Referencias: [research.md](../research.md) §2–§4 · FR-013, FR-014, FR-015, FR-016 · Historias 6 y 7

Se configuran **a mano** en la UI de Sentry (organización Aeropass, proyecto `aeropass-app`). Este archivo es la fuente para recrearlos: si alguien cambia un umbral en la UI, la UI manda (Edge Cases del spec) y se actualiza este archivo en el siguiente PR.

## Dashboard "AeroPass App — Observabilidad"

Filtro global del dashboard: **Environment** (valores `prod`, `demo`, `dev`, `dev-offline`). Todos los widgets respetan el filtro; por defecto `prod`.

| # | Widget | Dataset | Consulta | Visualización |
|---|---|---|---|---|
| W1 | Sesiones libres de crash | Releases | `crash_free_rate(session)` agrupado por release | Línea |
| W2 | Usuarios libres de crash | Releases | `crash_free_rate(user)` agrupado por release | Línea |
| W3 | Conversión de onboarding | Logs | A = `count_unique(aeropass.enrollment_attempt_id)` con `aeropass.event:credential_activated_shown`; B = igual con `aeropass.event:capture_step_entered`; ecuación `A / B` | Número grande + línea |
| W4 | Duración del registro p90 | Application Metrics | `p90(enrollment.duration)` | Número grande (meta ≤ 180.000 ms) |
| W5 | Embudo por paso | Logs | `count_unique(aeropass.enrollment_attempt_id)` agrupado por `aeropass.event` con `aeropass.event:[capture_step_entered, confirmation_step_entered, selfie_instructions_step_entered, liveness_step_entered, verification_step_entered, credential_activated_shown]` | Barras |
| W6 | Auto rechazo del dispositivo | Logs | `count()` de `capture_device_rejected` ÷ `count()` de `capture_attempted` | Número + línea |
| W7 | Auto rechazo del backend | Logs | `count()` de `capture_verification_rejected` ÷ `count()` de `capture_attempted` | Número + línea |
| W8 | Resultado de liveness | Logs | `count()` de `liveness_outcome` agrupado por `aeropass.outcome` (`attackDetected` visible por separado) | Barras apiladas |
| W9 | Rendimiento de pantallas críticas | Spans | `p95(span.duration)` de las transacciones de navegación de las rutas críticas, agrupado por nombre de ruta | Tabla |
| W10 | Tiempo hasta el pase utilizable | Spans | `p95` de TTFD de la ruta del pase y del span de inicio de la app | Número (meta ≤ 3 s) |
| W11 | Eventos de seguridad y contingencia | Errors | `count()` con `failure_class:*` agrupado por `failure_class` | Barras |

## Reglas de alerta (canal: correo; destinatario: lo define el usuario al crear cada regla)

| # | Regla | Dataset / condición | Periodo | Entornos | Notas |
|---|---|---|---|---|---|
| A1 | Fallo del servicio de verificación | Issue alert: evento con `failure_class:service` | Inmediata | Todos | Al crearla en un entorno, ese `env/*.env` declara `SENTRY_ALERT_RULE_CONFIRMED=true` (FR-015) |
| A2 | Pico de crashes en una versión nueva | Monitor sobre crash-free sessions por release, umbral < 99% | 1 hora | Todos | El correo indica versión y entorno |
| A3 | Conversión de onboarding baja | Monitor sobre la ecuación de W3, umbral < 0,90 | 1 hora | Solo `prod` | Ver desviación D1 |
| A4 | Registro lento | Monitor sobre `p90(enrollment.duration)`, umbral > 180.000 ms | 1 hora | Solo `prod` | Ver desviación D1 |

## Desviaciones conocidas frente al spec

- **D1 (FR-014)**: Sentry no permite condicionar un monitor a un volumen mínimo (≥10 intentos) ni esperar 15 minutos antes de contar un abandono (research §4). A3 y A4 evalúan la ventana de 1 hora tal cual. Aceptado por el usuario (2026-09-23); FR-014 ajustado. Con poco volumen pueden disparar por un solo abandono: revisar el volumen en W5 antes de actuar.

## Configuración del proyecto (una sola vez)

- Security & Privacy: activar "Prevent Storing of IP Addresses" y dejar activas las reglas de Data Scrubbing por defecto (research §5, segunda capa).
- Acceso a la organización limitado al equipo (Assumptions del spec, riesgo aceptado del `EnrollmentAttemptId`).
