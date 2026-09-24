---

description: "Tasks for 015-observabilidad-sentry (App móvil)"
---

# Tasks: Observabilidad con Sentry (App móvil)

**Input**: Design documents from `/specs/015-observabilidad-sentry/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: Incluidos donde el plan y la constitución los exigen: el filtro de privacidad y la lista blanca son frontera de confianza (Principio IV, test-first), y la cobertura mínima de CI es 85% en repositorios y servicios. Las tareas de prueba se escriben primero y deben fallar antes de implementar.

**Organization**: por historia de usuario del spec. Las Historias 8 (inyección de fallos) y 9 (métricas no priorizadas) están diferidas y no tienen tareas.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: se puede hacer en paralelo (archivos distintos, sin dependencias pendientes)
- **[Story]**: historia del spec (US1…US7)
- Rutas relativas a la raíz del repo `AeroPass-App/`

---

## Phase 1: Setup

**Purpose**: dependencias, entornos y configuración de arranque

- [ ] T001 Agregar `sentry_dart_plugin` a `dev_dependencies` y un bloque `sentry:` (org `aeropass`, project `aeropass-app`, `upload_debug_symbols: true`, `upload_source_maps: false`; el token se lee de la variable de entorno `SENTRY_AUTH_TOKEN`, nunca en el archivo) en `pubspec.yaml`; ejecutar `flutter pub get` y confirmar que `pubspec.lock` resuelve (research §9)
- [ ] T002 [P] Crear `env/demo.env` a partir de `env/dev-offline.env` (mismas banderas de backend falso), con `SENTRY_ENVIRONMENT=demo`, `SENTRY_SEND_TEST_EVENT=false`, `SENTRY_ALERT_RULE_CONFIRMED=false` y las cuatro tasas de muestreo en `1.0` (research §7, §12)
- [ ] T003 [P] Agregar `SENTRY_TRACES_SAMPLE_RATE`, `SENTRY_PROFILES_SAMPLE_RATE`, `SENTRY_REPLAY_SESSION_SAMPLE_RATE` y `SENTRY_REPLAY_ON_ERROR_SAMPLE_RATE` a `env/dev.env` y `env/dev-offline.env` (todas `1.0`) y a `env/prod.env` (`0.2`, `0.2`, `0.1`, `1.0`) (research §7)
- [ ] T004 [P] Agregar la configuración `"aeropass_app (demo)"` con `--dart-define-from-file=env/demo.env` en `.vscode/launch.json`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: muestreo configurable y emisor con varios destinos; sin cambio de comportamiento visible

**⚠️ CRITICAL**: US2, US3 y US4 dependen de esta fase

- [ ] T005 En `lib/core/sentry_config.dart`, reemplazar las constantes fijas `_tracesSampleRate`, `_profilesSampleRate`, `_replaySessionSampleRate` y `_replayOnErrorSampleRate` por valores leídos de las variables de T003 (`String.fromEnvironment` + `double.tryParse`), con los valores por defecto de prod como constantes con nombre (0.2, 0.2, 0.1, 1.0); un valor fuera de [0, 1] lanza `assert` en debug y cae al valor por defecto en release (data-model `TelemetryConfig`)
- [ ] T006 [P] Crear el puerto `AnalyticsSink` (`void record(String eventName, Map<String, Object?> payload)`, nunca lanza ni espera la red) y `DeveloperLogAnalyticsSink` (mueve aquí la escritura `developer.log(..., name: 'aeropass.analytics')` actual con `sessionId` y `timestamp`) en `lib/data/services/analytics_sink.dart` (research §11)
- [ ] T007 Modificar `LoggingAnalyticsEmitter` para que `_log` arme el payload una vez y lo entregue a cada `AnalyticsSink` de una lista recibida por constructor; nombres de eventos y payloads sin cambios, en `lib/data/services/logging_analytics_emitter.dart` (depende de T006)
- [ ] T008 En `lib/app/composition_root.dart`, construir `LoggingAnalyticsEmitter` con `sinks: [DeveloperLogAnalyticsSink(sessionId: sessionId, clock: clock)]` (depende de T007)
- [ ] T009 Ajustar los tests existentes que construyen el emisor (`test/unit/pass_analytics_payload_test.dart`, `test/unit/technical_error_analytics_payload_test.dart`, `test/unit/trips_analytics_payload_test.dart` y cualquier otro que falle) a la nueva firma, y confirmar `flutter test` en verde (depende de T007)

**Checkpoint**: la app se comporta igual que antes; el emisor ya admite más destinos

---

## Phase 3: User Story 1 - Cero datos personales en toda la observabilidad (Priority: P1) 🎯 MVP

**Goal**: ningún evento enviado a Sentry lleva IP, usuario ni datos prohibidos; un solo filtro central; Replay oculta el QR y las vistas de cámara

**Independent Test**: quickstart §2 y §4: crash de prueba sin sección *User* ni IP; grabación de Replay con todas las pantallas sensibles ocultas

### Tests for User Story 1 ⚠️ (escribir primero, deben fallar)

- [ ] T010 [P] [US1] Escribir `test/unit/sentry_privacy_filter_test.dart` con las 6 garantías de `contracts/privacy-filter.md` (evento sin `user`/IP/`request`; log sin atributos fuera de la lista blanca; log descartado si su mensaje ≠ `aeropass.event`; métrica no listada descartada; breadcrumb de consola o de entrada de texto descartado y de navegación sin `extra`; evento `verification_service_failure` de 011 conserva sus etiquetas y pierde el usuario)

### Implementation for User Story 1

- [ ] T011 [US1] Implementar `SentryPrivacyFilter` en `lib/data/services/sentry_privacy_filter.dart` con métodos para `beforeSend`, `beforeSendTransaction`, `beforeBreadcrumb`, `beforeSendLog` y `beforeSendMetric`; la lista blanca de atributos de logs (`aeropass.event`, `aeropass.session_id`, `aeropass.enrollment_attempt_id` y las claves de payload de `contracts/telemetry-events.md` §1) y la de métricas (`enrollment.duration` con `aeropass.resumed`) como constantes `Set<String>` públicas para que T017 las compare (depende de T010)
- [ ] T012 [US1] En `lib/core/sentry_config.dart`: `sendDefaultPii = false`; conectar los cinco hooks al filtro de T011; eliminar `stripAlertEventPii` (su caso queda cubierto por el filtro) (depende de T011)
- [ ] T013 [US1] Reescribir `test/unit/sentry_before_send_test.dart` para que pruebe el evento de alerta de 011 a través de `SentryPrivacyFilter` en lugar de `stripAlertEventPii` (no regresión; depende de T012)
- [ ] T014 [US1] En `SentryConfig.configure` (`lib/core/sentry_config.dart`), agregar `options.privacy.mask<QrCodeView>()`, `mask<SelfieFramePreview>()` y `mask<LivenessOvalOverlay>()` junto al `mask<CameraPreview>()` existente, con los imports de `lib/features/pass/widgets/qr_code_painter.dart`, `lib/features/enrollment/selfie/widgets/selfie_frame_preview.dart` y `lib/features/enrollment/liveness/widgets/liveness_oval_overlay.dart` (research §6)
- [ ] T015 [US1] Paso manual en Sentry, proyecto `aeropass-app` → Settings → Security & Privacy: activar "Prevent Storing of IP Addresses" y confirmar las reglas de Data Scrubbing por defecto (`contracts/dashboard-and-alerts.md`, "Configuración del proyecto")
- [ ] T016 [US1] Validar quickstart §2 (crash de prueba en `dev`) y §4 (grabación de Replay en `demo` con la tabla de pantallas); si una pantalla muestra datos, agregar su widget a las máscaras de T014 antes de continuar

**Checkpoint**: la condición previa a publicar que registró 011 (`sendDefaultPii`) queda resuelta

---

## Phase 4: User Story 2 - Eventos de negocio visibles en Sentry (Priority: P1)

**Goal**: cada evento del `AnalyticsEmitter` llega a Sentry como log estructurado, con `aeropass.enrollment_attempt_id` desde el consentimiento

**Independent Test**: quickstart §3: un log por evento en *Explore → Logs*, sin atributos fuera del contrato

**Depende de**: Phase 2 y US1 (el filtro aplica la lista blanca a los logs)

### Tests for User Story 2 ⚠️ (escribir primero, deben fallar)

- [ ] T017 [P] [US2] Escribir `test/contract/telemetry_allowlist_contract_test.dart`: lee `lib/data/services/logging_analytics_emitter.dart` como texto, extrae las claves de los payloads de `_log` (regex `'([a-zA-Z]+)':`, excluyendo `event`, `sessionId`, `timestamp`), las convierte a `aeropass.<snake_case>` y exige que el conjunto sea igual a la lista blanca de payload de `SentryPrivacyFilter` (falla si alguien agrega una clave sin actualizar el contrato)
- [ ] T018 [P] [US2] Escribir `test/unit/current_enrollment_attempt_test.dart`: `null` sin registro de consentimiento; toma el `enrollmentAttemptId` del registro local al cargar; se actualiza cuando `recordConsent` devuelve `Ok`; vuelve a `null` cuando `withdraw` devuelve `Ok`; no cambia cuando cualquiera devuelve `Error`
- [ ] T019 [P] [US2] Escribir `test/unit/sentry_log_analytics_sink_test.dart` con un escritor de logs inyectado (sin SDK): mensaje = nombre del evento; atributos `aeropass.event`, `aeropass.session_id` y el payload en `aeropass.<snake_case>`; `aeropass.enrollment_attempt_id` presente solo si hay intento vigente; `record` retorna sin esperar

### Implementation for User Story 2

- [ ] T020 [US2] Implementar `CurrentEnrollmentAttempt` (valor en memoria, `Future<void> load()` que lee `ConsentRepository.getLocalRecord()` una vez, `set`/`clear`) en `lib/data/services/current_enrollment_attempt.dart` (depende de T018)
- [ ] T021 [US2] Implementar el decorador `AttemptTrackingConsentRepository implements ConsentRepository` en `lib/data/services/attempt_tracking_consent_repository.dart`: delega todo en el repositorio envuelto y actualiza `CurrentEnrollmentAttempt` cuando `recordConsent` (set) o `withdraw` (clear) devuelven `Ok`; sin modificar `ConsentRepositoryImpl` ni `DevConsentRepository` (depende de T020)
- [ ] T022 [US2] Implementar `SentryLogAnalyticsSink implements AnalyticsSink` en `lib/data/services/sentry_log_analytics_sink.dart`, con un escritor inyectable cuyo valor por defecto llama a `Sentry.logger.info(eventName, attributes: …)` con `SentryAttribute` según el tipo (string, int, bool, enum por nombre), sin `await` en el camino del emisor (depende de T019)
- [ ] T023 [US2] En `lib/app/composition_root.dart`: crear `CurrentEnrollmentAttempt`, envolver el `consentRepository` elegido (real o dev) con `AttemptTrackingConsentRepository`, llamar a `load()` sin bloquear la construcción, y agregar `SentryLogAnalyticsSink` a los `sinks` del emisor solo si `SentryConfig.isEnabled` (depende de T021, T022)
- [ ] T024 [US2] Validar quickstart §3 en `dev` (incluido el caso sin red); confirmar en Sentry que no aparecen atributos fuera del contrato

**Checkpoint**: el embudo ya es visible en Sentry; sin DSN, la app sigue escribiendo solo en el log local

---

## Phase 5: User Story 3 - Tasa de conversión/finalización de onboarding (Priority: P1)

**Goal**: conversión por `EnrollmentAttemptId` (en Sentry, con `count_unique`) y métrica `enrollment.duration` para el p90 de registros sin reinicio

**Independent Test**: quickstart §5 pasos 2–3: W3 = 80% con 4 de 5 intentos (el retomado cuenta una vez) y W4 calculado sin el retomado

**Depende de**: US2

### Tests for User Story 3 ⚠️ (escribir primero, deben fallar)

- [ ] T025 [P] [US3] Escribir `test/unit/enrollment_duration_tracker_test.dart` con `Clock` falso y escritor de métricas inyectado: el primer `capture_step_entered` de un intento fija el inicio y los siguientes no lo cambian; `credential_activated_shown` emite `enrollment.duration` en ms con `aeropass.resumed=false` y descarta el inicio; sin inicio en este arranque (retomado) no emite nada; sin intento vigente no emite nada

### Implementation for User Story 3

- [ ] T026 [US3] Implementar `EnrollmentDurationTracker` (mapa en memoria `EnrollmentAttemptId → DateTime` del `Clock` inyectado; escritor por defecto `Sentry.metrics.distribution('enrollment.duration', ms, unit: 'millisecond', attributes: …)`) en `lib/data/services/enrollment_duration_tracker.dart` (depende de T025; data-model `EnrollmentTiming`)
- [ ] T027 [US3] Hacer que `SentryLogAnalyticsSink` notifique al tracker en `capture_step_entered` y `credential_activated_shown`, con el intento vigente de `CurrentEnrollmentAttempt`, en `lib/data/services/sentry_log_analytics_sink.dart`; cablear el tracker en `lib/app/composition_root.dart` (depende de T026)
- [ ] T028 [US3] Validar quickstart §5 pasos 2–3 en `demo` (W3, W4 y W5 con la consulta del contrato, aunque el dashboard aún no exista: usar *Explore*)

**Checkpoint**: la conversión y el p90 se pueden calcular en Sentry

---

## Phase 6: User Story 6 - Dashboard y alertas en `aeropass-app` (Priority: P1)

**Goal**: dashboard con filtro de entorno y reglas de correo A1–A4 creadas a mano según `contracts/dashboard-and-alerts.md`

**Independent Test**: quickstart §5 paso 4: correo de A1 en menos de 2 minutos y mensaje "Nuestro equipo ya fue notificado"

**Depende de**: US2 y US3 para W3–W5; W1, W2 y W11 funcionan desde US1

- [ ] T029 [US6] Crear en Sentry el dashboard "AeroPass App — Observabilidad" con el filtro global de entorno y los widgets W1–W5 y W11 exactamente como en `contracts/dashboard-and-alerts.md`; anotar la URL del dashboard en ese contrato
- [ ] T030 [US6] Crear las reglas A1 (issue alert `failure_class:service`, todos los entornos), A2 (crash-free sessions < 99% por release, 1 hora, todos), A3 (ecuación de W3 < 0,90, 1 hora, solo `prod`) y A4 (`p90(enrollment.duration)` > 180000 ms, 1 hora, solo `prod`), con acción de correo al destinatario que defina el usuario
- [ ] T031 [US6] Poner `SENTRY_ALERT_RULE_CONFIRMED=true` en `env/demo.env`, `env/dev.env` y `env/prod.env` solo después de comprobar que A1 cubre ese entorno (FR-015)
- [ ] T032 [US6] Validar quickstart §5 paso 4 en `demo` (correo de A1 < 2 min; pantalla de error técnico con "Nuestro equipo ya fue notificado")

**Checkpoint**: el equipo recibe correos sin mirar el dashboard

---

## Phase 7: User Story 7 - Demostración en 15 minutos (Priority: P1)

**Goal**: el dashboard tiene cifras al empezar la presentación y las alertas inmediatas se ven en vivo

**Independent Test**: ensayo de 15 minutos con SC-009

**Depende de**: US1, US2, US3, US6 (y US4/US5 si se quieren mostrar W6–W10)

- [ ] T033 [US7] Ejecutar la preparación de quickstart §6 con `env/demo.env` en un emulador o dispositivo; anotar en `specs/015-observabilidad-sentry/quickstart.md` §6 el tiempo real que tomó y cualquier paso que faltara
- [ ] T034 [US7] Ensayar la presentación de 15 minutos (acciones en vivo de quickstart §6) y confirmar SC-009: cifras desde el primer minuto y correo de A1 en menos de 2 minutos

**Checkpoint**: presentación lista

---

## Phase 8: User Story 4 - Tasa de auto rechazo (Priority: P2)

**Goal**: tres tasas separadas (dispositivo, backend, liveness con `attackDetected` aparte)

**Independent Test**: forzar rechazos en `demo` y ver W6–W8 con los valores esperados

**Depende de**: US2 (los eventos ya fluyen; no requiere código nuevo)

- [ ] T035 [US4] Agregar los widgets W6, W7 y W8 al dashboard según `contracts/dashboard-and-alerts.md`
- [ ] T036 [US4] Validar en `demo`: 2 rechazos del dispositivo y 1 del backend sobre intentos conocidos; W6 y W7 muestran la proporción esperada y W8 separa `attackDetected`

---

## Phase 9: User Story 5 - Rendimiento de pantallas críticas y del pase (Priority: P2)

**Goal**: trazas por nombre de ruta, TTFD en pantallas críticas y tiempo hasta el pase utilizable

**Independent Test**: en el dispositivo mínimo de referencia, W9 y W10 muestran duraciones por ruta y el tiempo hasta el pase

- [ ] T037 [P] [US5] Agregar `name:` a cada `GoRoute` de `lib/app/router.dart` con constantes nuevas en una clase `AppRouteNames` junto a `AppRoutes` (mismo archivo), sin cambiar los paths
- [ ] T038 [P] [US5] Crear el puerto `FullDisplayReporter` (`void reportFullyDisplayed()`) con `SentryFullDisplayReporter` (llama a `SentryFlutter.currentDisplay()?.reportFullyDisplayed()`) y `NoopFullDisplayReporter` en `lib/data/services/full_display_reporter.dart`, y proveerlo en `lib/app/composition_root.dart` según `SentryConfig.isEnabled` (constructor injection; ninguna vista llama a Sentry directamente, Principio IX)
- [ ] T039 [US5] En `SentryConfig.configure` (`lib/core/sentry_config.dart`) activar `enableTimeToFullDisplayTracing = true` (depende de T037)
- [ ] T040 [US5] Inyectar `FullDisplayReporter` y llamar a `reportFullyDisplayed()` cuando el contenido está listo en `lib/features/pass/pass_view.dart` (tras el primer frame con el QR dibujado) y en las vistas de captura de documento, confirmación, liveness, verificación en curso y credencial activada bajo `lib/features/enrollment/` (tras el primer frame con contenido); agregar tests de widget que verifiquen la llamada con un reporter falso (depende de T038, T039)
- [ ] T041 [US5] Agregar los widgets W9 y W10 al dashboard según `contracts/dashboard-and-alerts.md`
- [ ] T042 [US5] Validar en el dispositivo mínimo de referencia: W9 muestra p95 por nombre de ruta y W10 el tiempo hasta el pase (meta ≤ 3 s)

---

## Phase 10: Polish & Cross-Cutting Concerns

- [ ] T043 [P] Documentar en `README.md` la sección de observabilidad: variables de `env/*.env` (DSN, entorno, muestreo, `SENTRY_ALERT_RULE_CONFIRMED`), `env/demo.env`, el comando de release con `--obfuscate --split-debug-info` y la subida de símbolos con `dart run sentry_dart_plugin` usando `SENTRY_AUTH_TOKEN`
- [ ] T044 [P] Anotar en `specs/011-error-tecnico/research.md` §7 que la condición previa sobre `sendDefaultPii` quedó resuelta por 015 (una línea con enlace a este spec)
- [ ] T045 Compilar un release con símbolos separados, subirlos y validar quickstart §7 (pila legible en Sentry)
- [ ] T046 `flutter analyze` sin advertencias, `flutter test` en verde y cobertura ≥ 85% en `lib/data/services/` para los archivos nuevos (gates de CI de la constitución)
- [ ] T047 Recorrer `quickstart.md` completo (§1–§7) en `demo` y marcar cualquier desviación en `contracts/dashboard-and-alerts.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sin dependencias
- **Foundational (Phase 2)**: después de Setup; bloquea US2, US3 y US4
- **US1 (Phase 3)**: después de Setup (T005 no es necesario para US1, pero sí antes de publicar); bloquea US2 (el filtro aplica la lista blanca a los logs)
- **US2 → US3 → US6 → US7**: cadena principal del MVP de la presentación
- **US4 (Phase 8)**: después de US2 y de que exista el dashboard (T029)
- **US5 (Phase 9)**: independiente de US2–US4; W9/W10 necesitan el dashboard (T029)
- **Polish**: al final

### User Story Dependencies

| Historia | Depende de | Notas |
|---|---|---|
| US1 | Setup | MVP de privacidad; se puede publicar sola |
| US2 | Foundational, US1 | |
| US3 | US2 | |
| US6 | US1 (W1, W2, W11), US2 + US3 (W3–W5) | configuración manual en Sentry |
| US7 | US1, US2, US3, US6 | ensayo de la presentación |
| US4 | US2, T029 | solo dashboard y validación |
| US5 | Setup, T029 para los widgets | independiente del embudo |

### Within Each User Story

- Tests primero y en rojo (US1, US2, US3, US5)
- Modelos y puertos antes que servicios; servicios antes del cableado en `composition_root.dart`
- Validación con quickstart al final de cada historia

## Parallel Opportunities

- Setup: T002, T003 y T004 en paralelo
- Foundational: T006 en paralelo con T005
- US1: T010 solo; luego T014 puede ir en paralelo con T011–T013 (mismo archivo que T012: coordinar)
- US2: T017, T018 y T019 en paralelo; T020 y T022 en paralelo después
- US5: T037 y T038 en paralelo; toda US5 puede avanzar en paralelo a US2–US3 si hay dos personas

## Parallel Example: User Story 2

```text
Task: "T017 Contract test de la lista blanca en test/contract/telemetry_allowlist_contract_test.dart"
Task: "T018 Tests de CurrentEnrollmentAttempt en test/unit/current_enrollment_attempt_test.dart"
Task: "T019 Tests de SentryLogAnalyticsSink en test/unit/sentry_log_analytics_sink_test.dart"
```

## Implementation Strategy

### MVP First (User Story 1)

1. Setup + Foundational
2. US1 → validar quickstart §2 y §4 → la app ya puede publicarse sin enviar datos personales

### Camino a la presentación

1. MVP (US1)
2. US2 → US3 → US6 → US7: embudo, conversión, dashboard/alertas y ensayo
3. Si hay tiempo antes de la presentación: US4 (solo widgets) y US5

### Parallel Team Strategy

- Persona A: US1 → US2 → US3
- Persona B: Setup → US5 → luego US6/US4 (configuración en Sentry) cuando A termine US3

## Notes

- Las Historias 8 y 9 están diferidas: no generan tareas.
- Las tareas de Sentry (T015, T029–T031, T035, T041) son manuales en la UI; su definición está en `contracts/dashboard-and-alerts.md`.
- Commit por tarea o grupo lógico; los mensajes no mencionan a Claude.
