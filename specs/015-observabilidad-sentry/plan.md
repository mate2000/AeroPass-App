# Implementation Plan: Observabilidad con Sentry (App móvil)

**Branch**: `observabilidad` | **Date**: 2026-09-23 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/015-observabilidad-sentry/spec.md`

## Summary

Extender la integración de Sentry que ya existe desde 011 para que la app (1) no envíe datos personales en ningún evento, (2) lleve a Sentry los eventos del embudo que hoy solo quedan en el log local, (3) permita calcular la conversión de onboarding, su p90 y las tasas de auto rechazo, y (4) tenga un dashboard y alertas por correo en el proyecto `aeropass-app`, además de una forma reproducible de preparar la presentación de 15 minutos.

Enfoque técnico (detalle en [research.md](research.md)):
- **Privacidad**: `sendDefaultPii = false` y un único `SentryPrivacyFilter` en los cinco puntos de salida del SDK, con lista blanca para logs y métricas; ocultar en Session Replay los widgets de `CustomPainter` sensibles, incluido el QR.
- **Embudo**: el emisor de analítica existente pasa a escribir en varios destinos; uno nuevo envía cada evento como log estructurado de Sentry, etiquetado con el `EnrollmentAttemptId` vigente.
- **Métricas**: conversión con `count_unique` sobre logs; p90 con una métrica de distribución emitida solo para registros sin reinicio (sin guardar nada nuevo).
- **Costo**: tasas de muestreo por entorno, más bajas en prod.
- **Operación**: dashboard y alertas creados a mano según [contracts/dashboard-and-alerts.md](contracts/dashboard-and-alerts.md); símbolos de depuración con `sentry_dart_plugin`.

## Technical Context

**Language/Version**: Dart / Flutter 3.47.5 (`.fvmrc`), SDK `^3.13.4`

**Primary Dependencies**: `sentry_flutter` ^9.30.0 (ya presente; resuelve 9.30.1, que trae logs, métricas y los hooks `beforeSendLog`/`beforeSendMetric`); nueva dependencia de desarrollo `sentry_dart_plugin` (subida de símbolos); `go_router`, `provider` (existentes)

**Storage**: N/A. No se persiste nada nuevo (Principio I); se reutiliza el `EnrollmentAttemptId` ya guardado con el consentimiento

**Testing**: `flutter_test` + `mocktail`; unitarias del filtro de privacidad y de los destinos de analítica; prueba de contrato de la lista blanca contra las claves del emisor; verificación manual de Session Replay y del dashboard (quickstart §4–§6)

**Target Platform**: Android e iOS (Flutter mobile)

**Project Type**: mobile-app

**Performance Goals**: sin impacto perceptible (SC-008); cold start ≤3 s hasta el pase y 60 fps en captura/credencial (Principio V) se mantienen; ninguna llamada de telemetría espera la red

**Constraints**: cero datos personales en Sentry (Principio VII); 100% de errores, crashes y eventos del embudo; muestreo en trazas, profiling y replay; sin DSN no se envía nada; funciona sin conexión (el SDK encola)

**Scale/Scope**: ~70 tipos de eventos existentes; ~20 logs por intento; estimado de ~200.000 logs/mes con 10.000 registros (research §7); 1 dashboard de 11 widgets y 4 reglas de alerta

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Estado | Cómo se cumple |
|---|---|---|
| I. Consentimiento y minimización | ✅ | No se persiste nada nuevo (research §3, §10). Ningún artefacto crudo (imagen, frame) llega a Sentry: `attachScreenshot = false` y Replay con ocultamiento de cámara, textos, imágenes y `CustomPainter` sensibles. El `EnrollmentAttemptId` enviado es anónimo; el riesgo de enlace vía backend está aceptado por el usuario (spec, Assumptions). |
| II. Proveedor como adapter | ✅ | Sin cambios en el puerto de verificación. Los tipos de Sentry no entran en dominio ni presentación: viven en `data/services` y en `core/sentry_config.dart`. |
| III. Todo flujo tiene camino de fallo | ✅ | Sin pantallas nuevas. Si Sentry falla, la telemetría se descarta en silencio (FR-012); ningún flujo depende de ella. La inyección de fallos está diferida. |
| IV. Test-first en la frontera de confianza | ✅ | El filtro de privacidad se trata como frontera: sus pruebas se escriben primero (contracts/privacy-filter.md). La prueba de contrato de la lista blanca también va antes. |
| V. Restricciones de aeropuerto | ✅ | Envío asíncrono y encolado del SDK; muestreo reducido en prod baja el costo en CPU y red. TTFD del pase verifica el presupuesto de 3 s. |
| VI. Accesibilidad | N/A | Sin cambios de interfaz. |
| VII. Observabilidad sin PII | ✅ | Objetivo central de la feature: corrige `sendDefaultPii = true`, filtro único con lista blanca, conecta el embudo a un pipeline real con los eventos ya existentes. |
| VIII. Arquitectura | ✅ | Puerto `AnalyticsEmitter` (dominio) sin cambios; destinos y proveedor del intento en `data/services`; cableado en `CompositionRoot`. Ninguna vista ni ViewModel importa Sentry. |
| IX. Patrones obligatorios | ✅ | Inyección por constructor desde el composition root; tipos inmutables; el acceso a la API estática de Sentry queda encapsulado en servicios (mismo patrón que `SentryOperationalAlertReporter` de 011). |
| X. Estándares de código | ✅ | Tasas de muestreo y umbrales como constantes con nombre (sin valores mágicos); un único lugar para nombres de eventos (DRY); `sentry_dart_plugin` justificado (research §9). |
| Seguridad: dependencias | ✅ | `sentry_flutter` ya estaba y fue revisado en 011; esta feature reduce su alcance (sin PII). `sentry_dart_plugin` es solo de compilación. |
| Seguridad: credenciales | ✅ | `SENTRY_AUTH_TOKEN` fuera del repo. El DSN es una clave pública de cliente (ya documentado en `env/dev.env`). |

**Re-check post-diseño (Phase 1)**: sin cambios; los contratos no introducen persistencia, tipos de proveedor en dominio ni nuevas pantallas. Las dos entradas de Complexity Tracking están justificadas abajo.

## Project Structure

### Documentation (this feature)

```text
specs/015-observabilidad-sentry/
├── plan.md                         # este archivo
├── research.md                     # Phase 0
├── data-model.md                   # Phase 1
├── quickstart.md                   # Phase 1
├── contracts/
│   ├── telemetry-events.md         # lista blanca de logs y métricas
│   ├── privacy-filter.md           # SentryPrivacyFilter
│   └── dashboard-and-alerts.md     # widgets, reglas y configuración del proyecto
└── tasks.md                        # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart                                   # sin cambios de forma; sigue usando SentryConfig
├── core/
│   └── sentry_config.dart                      # MODIFICA: sendDefaultPii=false, tasas por entorno, hooks del filtro, máscaras de Replay
├── app/
│   ├── composition_root.dart                   # MODIFICA: cablea sinks, CurrentEnrollmentAttempt y el filtro
│   └── router.dart                             # MODIFICA: `name` en cada GoRoute; TTFD en pantallas críticas
├── data/services/
│   ├── logging_analytics_emitter.dart          # MODIFICA: _log delega en List<AnalyticsSink>
│   ├── analytics_sink.dart                     # NUEVO: puerto AnalyticsSink + DeveloperLogAnalyticsSink
│   ├── sentry_log_analytics_sink.dart          # NUEVO: logs del embudo + métrica enrollment.duration
│   ├── current_enrollment_attempt.dart         # NUEVO: intento vigente en memoria
│   ├── sentry_privacy_filter.dart              # NUEVO: filtro central (reemplaza stripAlertEventPii)
│   └── sentry_operational_alert_reporter.dart  # sin cambios de comportamiento
└── features/
    ├── pass/widgets/qr_code_painter.dart       # referencia para la máscara de Replay (sin cambios)
    └── pass/…                                  # MODIFICA: reportFullyDisplayed cuando el QR está dibujado

env/
├── dev.env, dev-offline.env, prod.env          # MODIFICA: variables de muestreo
└── demo.env                                    # NUEVO: backends falsos, SENTRY_ENVIRONMENT=demo, muestreo 100%

test/
├── unit/
│   ├── sentry_privacy_filter_test.dart         # NUEVO (primero)
│   ├── sentry_log_analytics_sink_test.dart     # NUEVO
│   ├── current_enrollment_attempt_test.dart    # NUEVO
│   └── sentry_before_send_test.dart            # MODIFICA: pasa a probar el filtro general
└── contract/
    └── telemetry_allowlist_contract_test.dart  # NUEVO: lista blanca = claves del emisor

pubspec.yaml                                    # MODIFICA: sentry_dart_plugin (dev) + bloque de configuración del plugin
```

**Structure Decision**: app Flutter única con la organización existente (`core/`, `app/`, `data/services/`, `features/`). Todo lo que toca Sentry vive en `core/sentry_config.dart` y `data/services/`, siguiendo el patrón que dejó 011. Configuración manual en Sentry documentada en `contracts/dashboard-and-alerts.md`.

## Complexity Tracking

| Violación / desviación | Por qué hace falta | Alternativa más simple descartada porque |
|---|---|---|
| Dos mecanismos de telemetría: logs (conversión, embudo, rechazos) y una métrica de distribución (p90) | Los logs dan `count_unique` para no contar dos veces un registro retomado; las métricas dan p90 nativo | Solo logs: el p90 sobre atributos de logs no está documentado como soportado. Solo métricas: sin `count_unique`, un registro retomado se cuenta dos veces salvo que se guarde estado nuevo (enmienda del Principio I). |
| El p90 excluye los registros retomados en otro arranque (aceptado; FR-007 ajustado) | Medirlos exige guardar la hora de inicio en el dispositivo | Guardarla exige enmendar el Principio I, y su duración (horas con la app cerrada) no representa el esfuerzo del pasajero (research §3). |
| **D1 — Alertas A3/A4 sin volumen mínimo ni plazo de 15 minutos** | Sentry no permite esas condiciones en un monitor | **Aceptada por el usuario (2026-09-23); FR-014 ajustado.** La alternativa exacta, un evaluador programado en el backend que consulte la API de Sentry, es código nuevo y contradice la configuración manual (FR-016). |
