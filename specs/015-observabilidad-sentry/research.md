# Research: Observabilidad con Sentry (App móvil)

**Feature**: 015-observabilidad-sentry · **Fecha**: 2026-09-23 · **Spec**: [spec.md](spec.md)

Cada sección registra una decisión: qué se eligió, por qué y qué se descartó. Las capacidades de Sentry se verificaron contra la documentación vigente y contra el SDK instalado (`sentry` / `sentry_flutter` 9.30.1 en el pub cache).

---

## §1 — Canal para los eventos del embudo: Sentry Logs

**Decisión**: los eventos del `AnalyticsEmitter` se envían como **logs estructurados** de Sentry (`Sentry.logger.info`), un log por evento, con el nombre del evento y su payload como atributos. `enableLogs` ya está activo desde 011.

**Por qué**:
- Los logs no se muestrean en el cliente: llegan todos (spec, Q2 de Clarifications: 100% del embudo).
- El dataset de logs admite `count_unique(atributo)`, que es lo que permite contar intentos de registro sin duplicarlos (§2).
- Los logs admiten widgets de dashboard y alertas.
- No crean issues: un evento del embudo no es un error y no debe ensuciar la lista de problemas ni el conteo de crashes.

**Alternativas descartadas**:
- *Eventos de error (`captureMessage`)*: crean issues, consumen la cuota de errores y confunden la salud de la app.
- *Spans*: se muestrean con `tracesSampleRate`; perderían eventos del embudo.
- *Application Metrics para todo*: no tienen `count_unique`, así que un registro retomado (que vuelve a emitir `captureStepEntered`) se contaría dos veces. Se usan solo para el p90 (§3).

## §2 — Conversión de onboarding sin contar dos veces un registro retomado

**Decisión**: la conversión se calcula en Sentry como
`count_unique(enrollment_attempt_id)` de los logs `credential_activated_shown` ÷ `count_unique(enrollment_attempt_id)` de los logs `capture_step_entered`, con una ecuación en el widget.

**Por qué**: el `EnrollmentAttemptId` (Q1) es el mismo en todos los arranques de un intento, y `count_unique` lo cuenta una vez aunque el evento se repita. No hace falta guardar nada nuevo en el dispositivo.

**Comportamiento en ventanas de tiempo**: en una ventana de 1 hora, la ecuación compara intentos terminados con intentos empezados *en la misma ventana*. Con un p90 de 3 minutos, en régimen estable ambas cantidades se equilibran y la proporción aproxima la conversión real. Los intentos que empezaron en los últimos minutos de la ventana todavía no terminaron: ese es el sesgo que la regla de los 15 minutos (FR-007) busca evitar. Ver §4.

**Alternativa descartada**: contadores (`Sentry.metrics.count`) para inicios y finalizaciones: cuentan dos veces los registros retomados, salvo que se guarde en el dispositivo un marcador de "ya empezado", lo que exige enmendar el Principio I.

## §3 — p90 de la duración del registro sin guardar datos nuevos

**Decisión**: al emitir `credentialActivatedShown`, la app envía una métrica de distribución `enrollment.duration` (milisegundos) **solo si** vio el primer `captureStepEntered` del mismo intento en el mismo arranque (hora de inicio guardada solo en memoria). El p90 se lee directamente de la distribución.

**Por qué**:
- Las métricas de distribución admiten p90 de forma nativa.
- Para medir un registro retomado habría que guardar en el dispositivo la hora de inicio. El Principio I limita lo que se guarda a una lista cerrada; agregar esto exige enmendar la constitución.
- La duración de un registro retomado mide horas de reloj con la app cerrada, no el esfuerzo del pasajero; no es lo que busca el KR A1.4 ("tiempo que tarda en completar el registro").

**Consecuencia para el spec**: los registros retomados **sí** cuentan en la conversión (§2) pero **no** en el p90. Aceptado por el usuario (2026-09-23); FR-007 del spec quedó ajustado.

**Alternativa descartada**: guardar la hora de inicio en el almacenamiento seguro. Exige enmendar la constitución por una métrica que, para registros retomados, tampoco sería representativa.

## §4 — Alertas de conversión: lo que Sentry permite y lo que no

**Hallazgo**: los monitores de Sentry permiten umbrales sobre ecuaciones (`A / B`) en un periodo de tiempo, filtrados por entorno. **No** permiten dos cosas que pide FR-014:
1. Un volumen mínimo (≥10 intentos) como condición previa para evaluar.
2. Esperar 15 minutos después de que un intento empieza para contarlo como abandono.

**Decisión (aceptada por el usuario, 2026-09-23)**: implementar la alerta con lo que Sentry sí permite: monitor sobre la ecuación de §2, periodo de 1 hora, entorno `prod`, umbral 0,90. El mínimo de 10 intentos y el plazo de 15 minutos no se aplican en la alerta (sí en el análisis); FR-014 del spec quedó ajustado.

**Efecto esperado**: con volumen bajo, más falsas alarmas; el sesgo por intentos en curso es de unos pocos puntos (con un p90 de 3 minutos, solo los intentos de los últimos ~3 minutos de la ventana están incompletos).

**Alternativa que sí cumple FR-014 al pie de la letra (descartada por ahora)**: un evaluador programado (por ejemplo, un endpoint del backend llamado por QStash cada hora) que consulte la API de Sentry, aplique el mínimo y el plazo, y envíe un evento que dispare la alerta. Es código nuevo en el backend y contradice que las alertas se configuren a mano en la UI (FR-016).

## §5 — Un solo filtro central de datos personales

**Decisión**:
1. `sendDefaultPii = false`: corrige la condición previa a publicar que registró 011 (research §7 de 011).
2. Una clase única, `SentryPrivacyFilter`, conectada a **todos** los puntos de salida del SDK que existen en 9.30.1: `beforeSend`, `beforeSendTransaction`, `beforeBreadcrumb`, `beforeSendLog` y `beforeSendMetric`.
3. Para eventos y transacciones: quita usuario, IP, request y breadcrumbs no permitidos. Reemplaza al `stripAlertEventPii` de 011, que pasa a ser un caso del filtro general (FR-003).
4. Para logs y métricas: **lista blanca** de atributos. Solo pasan los nombres definidos en [contracts/telemetry-events.md](contracts/telemetry-events.md); cualquier otro atributo se descarta (FR-006).
5. Breadcrumbs: se conservan navegación (nombre de ruta, sin `extra` ni parámetros) y ciclo de vida de la app; se descartan los de consola y los de entrada de texto.
6. Segunda capa en el proyecto `aeropass-app` de Sentry: "Prevent Storing of IP Addresses" y las reglas de Data Scrubbing por defecto (paso manual en quickstart).

**Por qué lista blanca**: el Principio VII trata un campo prohibido como una fuga de la misma gravedad. Con lista negra, un campo nuevo pasa sin revisión; con lista blanca, no pasa hasta que alguien lo agrega al contrato.

## §6 — Session Replay y el QR del pase

**Hallazgo**: Session Replay oculta por defecto textos e imágenes, y 011 agregó `privacy.mask<CameraPreview>()`. El QR del pase se dibuja con un `CustomPainter` (`lib/features/pass/widgets/qr_code_painter.dart`), que no es texto ni imagen: **se grabaría sin ocultar**, y el payload del QR es un dato prohibido (Principio VII).

**Decisión**: agregar reglas de ocultamiento explícitas para el widget del QR y para los demás `CustomPainter` de pantallas sensibles (`selfie_frame_preview`, `liveness_oval_overlay`). La verificación antes de cada release (FR-004) se hace con la lista de pantallas de [quickstart.md](quickstart.md) §4.

## §7 — Tasas de muestreo con el costo en cuenta

**Decisión**: tasas configurables por entorno con `--dart-define-from-file` (variables nuevas `SENTRY_TRACES_SAMPLE_RATE`, `SENTRY_PROFILES_SAMPLE_RATE`, `SENTRY_REPLAY_SESSION_SAMPLE_RATE`, `SENTRY_REPLAY_ON_ERROR_SAMPLE_RATE`), con valores por defecto definidos como constantes con nombre:

| Señal | Hoy (011) | prod (propuesto) | dev / demo |
|---|---|---|---|
| Errores y crashes | 100% | 100% | 100% |
| Eventos del embudo (logs) | — | 100% | 100% |
| Trazas | 90% | 20% | 100% |
| Profiling (sobre las trazas muestreadas) | 100% | 20% | 100% |
| Replay de sesión | 60% | 10% | 100% |
| Replay con error | 100% | 100% | 100% |

**Por qué**: 20% de trazas da suficientes muestras para un p95 por pantalla con el volumen del piloto, y reduce ~4,5 veces el volumen de trazas frente a hoy. El replay es la señal más cara; el 100% con error conserva el valor de diagnóstico. En dev y demo el volumen es bajo y conviene ver todo.

**Costo de los logs del embudo**: unos 20 logs por intento de registro, de menos de 1 KB cada uno. Con 10.000 registros al mes (30% de adopción de un aeropuerto con 100.000 validaciones, KR A4.2), son ~200.000 logs, del orden de 0,2 GB al mes. Es un costo bajo frente al de trazas y replay.

## §8 — Rendimiento de pantallas críticas y tiempo hasta el pase

**Decisión**:
- Las rutas de go_router ya no llevan parámetros (verificado en `lib/app/router.dart`); se agrega `name` a cada `GoRoute` para que `SentryNavigatorObserver` nombre las trazas por ruta y no por path.
- Tiempo hasta pantalla visible y completa (TTID/TTFD) en captura, confirmación, liveness, validando, credencial y pase, con el soporte del SDK (`enableTimeToFullDisplayTracing` y `SentryDisplayWidget`/`reportFullyDisplayed`).
- Tiempo desde el arranque hasta el pase utilizable: span de inicio de la app del SDK + `reportFullyDisplayed` en la pantalla del pase cuando el QR está dibujado.

## §9 — Símbolos de depuración

**Decisión**: agregar `sentry_dart_plugin` como dependencia de desarrollo y compilar release con `--obfuscate --split-debug-info`. El token de subida (`SENTRY_AUTH_TOKEN`) va solo en el entorno de quien compila o en el secreto del CI; nunca en el repo (Development Workflow: credenciales fuera del repo).

**Justificación de la dependencia** (Security & Compliance): es una herramienta de compilación; no se incluye en la app, no accede a cámara, almacenamiento ni red del dispositivo.

## §10 — Cómo sabe el emisor el `EnrollmentAttemptId` vigente

**Decisión**: un proveedor en memoria, `CurrentEnrollmentAttempt`, en la capa de datos:
- Al arrancar, lee una vez el registro de consentimiento local (`ConsentRepository.getLocalRecord`) y guarda su `enrollmentAttemptId`.
- Se actualiza cuando `recordConsent` devuelve `Ok` (nuevo intento) y se limpia cuando se revoca el consentimiento.
- El emisor le pregunta el valor actual de forma síncrona; si no hay intento (bienvenida, antes del consentimiento), el evento sale sin ese atributo (FR-005).

**Por qué**: no agrega nada persistido (usa lo que ya guarda el consentimiento) y evita leer el almacenamiento seguro en cada evento.

## §11 — Emisor de analítica con varios destinos

**Decisión**: `LoggingAnalyticsEmitter` ya canaliza todos sus métodos por un único `_log(eventName, payload)`. Ese punto se convierte en una lista de destinos (`AnalyticsSink`): el log local actual y un nuevo `SentryLogAnalyticsSink`. Los nombres de eventos y sus payloads siguen definidos en un solo lugar (Principio X, DRY). Sin DSN, el composition root solo registra el destino local (FR-004 de 011, Historia 2 escenario 2).

**Alternativa descartada**: una segunda implementación completa de `AnalyticsEmitter` (40+ métodos) para Sentry: duplicaría cada nombre de evento y cada payload.

## §12 — Datos para la presentación

**Decisión**: un archivo de entorno nuevo `env/demo.env`: backends falsos (como `dev-offline`), `SENTRY_ENVIRONMENT=demo` y muestreo al 100%. El procedimiento de [quickstart.md](quickstart.md) §6 genera, al menos una hora antes, registros completados, abandonados y rechazados recorriendo la app de verdad, sin eventos fabricados.

**Por qué**: el dashboard filtra por `environment:demo`, sin mezclar datos de prueba con prod. Los datos salen del mismo camino de código que en producción, así que la demo prueba la instrumentación real.

**Alternativa descartada**: un "sembrador" que emita logs sintéticos sin recorrer la app: más rápido, pero la demo mostraría eventos que la app no generó.
