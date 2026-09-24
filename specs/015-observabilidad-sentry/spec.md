# Feature Specification: Observabilidad con Sentry (App móvil)

**Feature Branch**: `observabilidad`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "Aplicar observabilidad a la app móvil AeroPass con Sentry: captura de errores/crashes y tracing de rendimiento, respetando el Principio VII de la constitución ('Observabilidad sin PII'), llevando a Sentry las métricas de negocio priorizadas (conversión de onboarding, auto rechazo) y dejando configurados en el proyecto `aeropass-app` un dashboard y alertas por correo. Parte de la integración base de Sentry que ya existe en `main` (llegó con 011-error-tecnico) y no la duplica."

## Punto de partida: lo que ya existe en `main`

La feature `011-error-tecnico` dejó una integración base de Sentry. Este spec la **extiende y corrige**; no la reconstruye.

| Ya existe (no se vuelve a construir) | Dónde |
|---|---|
| Inicialización del SDK, desactivado cuando no hay DSN | `lib/main.dart`, `lib/core/sentry_config.dart` |
| DSN y entorno por flavor vía `--dart-define-from-file` | `env/dev.env`, `env/dev-offline.env`, `env/prod.env` |
| Captura de crashes (Dart, framework y nativos) y seguimiento de sesiones | `SentryConfig.configure` |
| Trazas de navegación entre pantallas | `SentryNavigatorObserver` en `lib/app/router.dart` |
| Capturas de pantalla en errores desactivadas | `attachScreenshot = false` |
| Evento de alerta operativa `failure_class:service` sin datos personales | `SentryOperationalAlertReporter`, `stripAlertEventPii` |

| Hallazgo en la base existente que este spec corrige | Por qué |
|---|---|
| `sendDefaultPii = true` para toda la app: los crashes y el resto de eventos pueden llevar la IP del dispositivo y datos de usuario | Viola el Principio VII ("crash reports ... MUST NEVER contain" datos personales). `011` lo dejó registrado como condición previa a publicar (research.md §7). La constitución prevalece sobre una preferencia previa (Governance). |
| Los eventos de analítica (`LoggingAnalyticsEmitter`) solo se escriben en el log local del dispositivo | Nadie puede ver la conversión de onboarding ni el auto rechazo. El propio archivo deja "conectarlo a un pipeline real" a la feature dueña de ese pipeline: esta. |
| Muestreo de 90% de trazas y 100% de profiling | Sin justificar frente al costo variable por validación (KR A4.3). |
| La regla de alerta sobre `failure_class:service` no existe todavía (`SENTRY_ALERT_RULE_CONFIRMED=false`) | Mientras no exista, la pantalla de error técnico no puede decir "Nuestro equipo ya fue notificado" (011 FR-006). |
| Session Replay activado (60% de sesiones, 100% con error), con textos, imágenes y cámara enmascarados | Se mantiene (decisión del usuario), pero el enmascarado pasa a verificarse en cada pantalla sensible antes de cada release (FR-004). |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Cero datos personales en toda la observabilidad (Priority: P1)

Como responsable de cumplimiento/privacidad, quiero que ningún evento enviado a Sentry —crash, error, traza, breadcrumb, log o evento de negocio— contenga datos personales o biométricos (IP del dispositivo, datos de usuario, imágenes de documento, frames de selfie o liveness, nombre, fecha de nacimiento, número de documento, token de credencial, payload de QR, respuestas crudas del proveedor de verificación), para cumplir el Principio VII y la Ley 1581.

**Why this priority**: Hoy la base existente envía datos personales por defecto en los crashes. Mientras eso siga así, la app no puede publicarse (condición registrada por 011), y cualquier métrica nueva que se envíe a Sentry heredaría el mismo problema.

**Independent Test**: Forzar un crash y un error durante la captura de documento y durante la selfie en una compilación de staging, y revisar los eventos recibidos en `aeropass-app`: ninguno lleva IP, usuario ni ninguno de los campos prohibidos.

**Acceptance Scenarios**:

1. **Given** un crash no controlado en cualquier pantalla, **When** llega a Sentry, **Then** no incluye la IP del dispositivo, datos de usuario ni ningún campo prohibido por el Principio VII.
2. **Given** un error durante la captura de documento o de selfie, **When** se genera el reporte, **Then** no contiene el frame ni ningún dato extraído del documento.
3. **Given** breadcrumbs de navegación o interacción previos a un error, **When** se inspeccionan, **Then** no incluyen ningún valor editado por el pasajero en la pantalla de confirmación.
4. **Given** el pasajero revoca su consentimiento, **When** se generan eventos después, **Then** no permiten re-identificarlo ni enlazarlo con datos revocados.
5. **Given** una grabación de Session Replay que recorre las pantallas de documento, selfie, liveness, confirmación, credencial y pase, **When** se reproduce en Sentry, **Then** los textos, imágenes y la cámara aparecen enmascarados y no se lee ningún dato del pasajero.

---

### User Story 2 - Eventos de negocio visibles en Sentry (Priority: P1)

Como responsable de producto, quiero que los eventos del embudo que la app ya emite (`AnalyticsEmitter`) lleguen a Sentry además del log local, para que las métricas de negocio se puedan calcular y graficar sin instrumentar las pantallas otra vez.

**Why this priority**: Es la condición para las Historias 3 y 4. Los eventos ya existen y ya están diseñados sin datos personales; solo falta que salgan del dispositivo.

**Independent Test**: Recorrer el flujo de enrolamiento en staging y confirmar que cada evento emitido aparece en `aeropass-app` con su nombre, su identificador de sesión anónimo y su payload, y con nada más.

**Acceptance Scenarios**:

1. **Given** una pantalla emite un evento del embudo, **When** hay conectividad, **Then** el evento llega a Sentry con el mismo nombre y payload definidos en su contrato `analytics-events.md`, sin campos añadidos.
2. **Given** no hay DSN configurado, **When** se emite el evento, **Then** solo se escribe en el log local, igual que hoy.
3. **Given** no hay conectividad, **When** se emite el evento, **Then** se envía al recuperar la red, sin bloquear ninguna pantalla.

---

### User Story 3 - Tasa de conversión/finalización de onboarding (KR A1.4, Priority: P1)

Como responsable de producto, quiero ver qué porcentaje de los pasajeros que empiezan a escanear su documento llegan a tener su Identidad Digital activa, y cuánto tardan (p90), para verificar el KR A1.4 (≥90% sin abandono, p90 ≤3 min).

**Why this priority**: Es el KR de negocio más ligado al valor que AeroPass vende (Objetivo A1).

**Independent Test**: Completar el flujo varias veces y abandonarlo en distintos pasos (captura, confirmación, selfie, liveness, validando); confirmar que la tasa y el p90 en Sentry corresponden a lo ejecutado.

**Acceptance Scenarios**:

1. **Given** las sesiones de un periodo, **When** se calcula la métrica, **Then** es (sesiones con `credentialActivatedShown` ÷ sesiones con `captureStepEntered`) × 100.
2. **Given** las sesiones que completaron, **When** se calcula la duración, **Then** es el p90 del tiempo entre `captureStepEntered` y `credentialActivatedShown` de la misma sesión.
3. **Given** una sesión abandonada, **When** se consulta, **Then** se puede ver el último paso alcanzado, para saber dónde se concentra el abandono.

---

### User Story 4 - Tasa de auto rechazo (Priority: P2)

Como responsable de calidad de captura, quiero ver qué porcentaje de los intentos de captura de documento y de liveness se rechazan automáticamente, separando los rechazos del propio dispositivo de los del backend, para saber en qué capa se concentra la fricción (informa al KR A2.3).

**Why this priority**: Explica una parte del abandono de la Historia 3 y se correlaciona con la métrica equivalente del backend.

**Independent Test**: Forzar capturas de baja calidad y capturas que el backend rechaza en staging; confirmar que ambas tasas en Sentry corresponden a lo ejecutado.

**Acceptance Scenarios**:

1. **Given** los intentos de captura de documento de un periodo, **When** se calcula la tasa del dispositivo, **Then** es (`captureDeviceRejected` ÷ `captureAttempted`) × 100.
2. **Given** los mismos intentos, **When** se calcula la tasa del backend, **Then** es (`captureVerificationRejected` ÷ `captureAttempted`) × 100, mostrada por separado.
3. **Given** los intentos de liveness, **When** se calcula su tasa, **Then** se deriva de `livenessOutcome` con resultado distinto de `success`, separando `attackDetected` del resto.

---

### User Story 5 - Rendimiento de pantallas críticas y del pase (Priority: P2)

Como ingeniero de plataforma, quiero ver el rendimiento de las pantallas de captura, confirmación, liveness, validando, credencial y pase, incluido el tiempo percibido al abrir o refrescar el pase, para verificar los presupuestos de la constitución (cold start ≤3 s con credencial emitida, 60 fps en captura y credencial) y tener el complemento del lado del cliente de la latencia de punto de control (KR A2.4).

**Why this priority**: La base ya traza la navegación; falta que las pantallas críticas y la carga del pase sean identificables y comparables con su presupuesto.

**Independent Test**: Ejecutar el flujo en el dispositivo mínimo de referencia y confirmar que Sentry muestra la duración por pantalla crítica y la del pase.

**Acceptance Scenarios**:

1. **Given** un pasajero recorre el flujo, **When** navega, **Then** Sentry muestra la duración de carga de cada pantalla crítica identificada por su nombre de ruta, sin parámetros que lleven datos personales.
2. **Given** un pasajero con credencial abre la app, **When** se muestra el pase, **Then** Sentry registra el tiempo desde el arranque hasta el pase utilizable.
3. **Given** una pantalla supera su presupuesto repetidamente en una versión, **When** se consulta, **Then** se ve como regresión de esa versión.

---

### User Story 6 - Dashboard y alertas en el proyecto `aeropass-app` (Priority: P1)

Como responsable de producto/soporte, quiero un dashboard en el proyecto `aeropass-app` (organización Aeropass, ya existente) con las métricas de las Historias 3–5 y la salud de la app, y alertas por correo cuando crucen su umbral, para enterarme de una degradación sin estar mirando el panel.

**Why this priority**: Sin panel ni alertas los datos existen pero nadie los ve a tiempo. Además, desbloquea el mensaje "Nuestro equipo ya fue notificado" que 011 dejó pendiente de esta regla.

**Independent Test**: Abrir el dashboard y verificar cada widget; provocar cada condición de alerta con datos de staging y confirmar que llega el correo.

**Acceptance Scenarios**:

1. **Given** el proyecto `aeropass-app`, **When** se abre el dashboard, **Then** muestra sin configuración adicional: sesiones y usuarios libres de crash por versión, tasa de conversión de onboarding y su p90, embudo por paso, tasas de auto rechazo (dispositivo, backend, liveness), rendimiento por pantalla crítica y tiempo hasta el pase.
2. **Given** existe la regla de alerta sobre `failure_class:service`, **When** llega un evento con esa etiqueta, **Then** se envía un correo al equipo, y el entorno correspondiente puede declarar `SENTRY_ALERT_RULE_CONFIRMED=true`.
3. **Given** la conversión baja de 90%, el p90 de registro supera 3 minutos, o hay un pico de crashes en una versión nueva, **When** se cruza el umbral, **Then** llega un correo que identifica la métrica y la versión, sin datos personales.

---

### User Story 7 - Métricas no priorizadas (Priority: N/A, diferida)

- **Tiempo de escalamiento a agente humano (KR A2.3, ≤90 s p95)**: ya no está bloqueado del lado de la app. `010-escalar-agente` define `escalationOutcome` con `elapsedSeconds`, pero su medición (010 FR-017/FR-018) está diferida por el modo happy-path de esa feature, y el backend de escalamiento (`/v1/escalations`) no existe en el repo de backend. Cuando 010 lo implemente, llegará a Sentry por el mismo camino de la Historia 2 sin trabajo adicional aquí, y podrá sumarse al dashboard.
- **Costo de fallover/contingencia**: es un cálculo financiero derivado (duración de la contingencia × costo), no un evento que la app emita.

**Why this priority**: No están entre las 3 métricas de negocio priorizadas; se documentan para no omitirlas en silencio.

**Acceptance Scenarios**:

1. **Given** 010 implemente su FR-018, **When** se emita `escalationOutcome`, **Then** llega a Sentry por el mecanismo de la Historia 2 sin cambios en este spec.

---

### Edge Cases

- Sin DSN (compilación local o de pruebas): la app funciona igual que hoy, sin enviar nada.
- Crash durante la captura de cámara: el frame en memoria nunca se adjunta.
- Sin conectividad: crashes y eventos se envían al recuperar la red, sin bloquear al pasajero ni afectar el pase ya emitido, que funciona sin red (Principio V).
- Sentry no responde: ninguna pantalla u operación se bloquea ni se retrasa.
- Dispositivo comprometido, fallo de pinning o backend no disponible: quedan como eventos propios, sin detalles que ayuden a evadir la protección.
- Pantallas de credencial y pase con bloqueo de captura: no se generan capturas de pantalla.
- Un evento de negocio con un campo no previsto en su contrato: no se envía ese campo.
- Alguien cambia un umbral de alerta en la UI de Sentry: la UI es la fuente de verdad del valor vigente; este spec fija qué se alerta y su meta de referencia (los KR).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La app DEBE conservar el comportamiento existente de 011: captura de crashes, sesiones, trazas de navegación, capturas de pantalla desactivadas, desactivación sin DSN y el evento de alerta operativa `failure_class:service`.
- **FR-002**: Ningún evento enviado a Sentry —crash, error, traza, breadcrumb, log, replay o evento de negocio— DEBE contener la IP del dispositivo, datos de usuario, imágenes de documento, frames de selfie o liveness, nombre, fecha de nacimiento, número de documento, token de credencial, payload de QR ni respuestas crudas del proveedor. Esto reemplaza el envío de datos personales por defecto que hoy aplica a toda la app.
- **FR-003**: El filtro de datos personales DEBE ser único y central, aplicado a todos los eventos, no solo al de alerta operativa.
- **FR-004**: Session Replay DEBE mantenerse activo en toda la app, con textos, imágenes y la vista de cámara enmascarados en todas las pantallas. El enmascarado DEBE verificarse en las pantallas de documento, selfie, liveness, confirmación, credencial y pase antes de cada release: ninguna grabación puede mostrar un dato prohibido por FR-002.
- **FR-005**: La app DEBE enviar a Sentry cada evento del `AnalyticsEmitter`, con el mismo nombre, payload e identificador de sesión anónimo de su contrato, manteniendo también el log local.
- **FR-006**: El envío de eventos de negocio NO DEBE añadir campos fuera del contrato de cada evento.
- **FR-007**: La app DEBE permitir calcular la tasa de conversión/finalización de onboarding (`credentialActivatedShown` ÷ `captureStepEntered` por sesión) y su p90 de duración.
- **FR-008**: La app DEBE permitir calcular por separado la tasa de auto rechazo del dispositivo, la del backend y la de liveness (separando `attackDetected`).
- **FR-009**: Las trazas de las pantallas críticas DEBEN identificarse por nombre de ruta sin parámetros que lleven datos personales, y DEBE existir una medición del tiempo desde el arranque hasta el pase utilizable.
- **FR-010**: Las tasas de muestreo de trazas, profiling y replay DEBEN definirse en el plan con justificación de costo frente al KR A4.3; los errores y crashes se capturan al 100%.
- **FR-011**: Todo evento DEBE llevar entorno (flavor) y versión de build, sin identificadores que re-identifiquen al pasajero.
- **FR-012**: La observabilidad NO DEBE bloquear ni retrasar ninguna pantalla u operación, incluso si Sentry no está disponible.
- **FR-013**: DEBE existir en `aeropass-app` un dashboard con los widgets de la Historia 6.
- **FR-014**: DEBEN existir reglas de alerta por correo para: eventos `failure_class:service`, conversión de onboarding <90%, p90 de registro >3 min, y pico de crashes en una versión nueva.
- **FR-015**: Una vez creada la regla sobre `failure_class:service`, el archivo de entorno correspondiente DEBE declarar `SENTRY_ALERT_RULE_CONFIRMED=true`, y solo entonces.
- **FR-016**: El dashboard y las alertas se configuran manualmente en la UI de Sentry en este ciclo, y el plan DEBE documentar cada widget y regla (consulta, umbral, destinatario) para poder recrearlos.
- **FR-017**: Los símbolos de depuración de cada build de release (Android e iOS) DEBEN subirse a Sentry para que los crashes muestren función y línea.

### Key Entities

- **Evento de error**: crash o excepción con pila de llamadas, pantalla, entorno, versión e id de sesión anónimo.
- **Evento de negocio**: un evento del `AnalyticsEmitter` enviado a Sentry, con el nombre y payload de su contrato.
- **Traza de rendimiento**: pantalla o transición medida, con duración, entorno y versión.
- **Regla de alerta**: umbral sobre una métrica, con correo como canal y un destinatario.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Cero eventos con IP, datos de usuario o campos prohibidos por el Principio VII en una auditoría de muestreo, incluidos crashes durante captura de documento y selfie. Con esto se cumple la condición previa a publicar que registró 011.
- **SC-002**: El 100% de los crashes aparece en Sentry en menos de 1 minuto desde que el dispositivo tiene conectividad.
- **SC-003**: La tasa de conversión de onboarding y su p90 se consultan en el dashboard sin pedirle datos a un desarrollador; metas de referencia ≥90% y ≤3 min.
- **SC-004**: Las tres tasas de auto rechazo se consultan por separado en el dashboard.
- **SC-005**: Soporte identifica la pantalla y la versión de una falla reportada sin pedir capturas ni pasos al pasajero en al menos el 90% de los casos.
- **SC-006**: Cuando una métrica cruza su umbral, el responsable recibe un correo sin estar mirando el dashboard.
- **SC-007**: La pantalla de error técnico muestra "Nuestro equipo ya fue notificado" en los entornos donde la regla existe, y solo en esos.
- **SC-008**: Ninguna operación del pasajero falla o se retrasa de forma perceptible por la observabilidad.

## Assumptions

- La organización de Sentry "Aeropass" y el proyecto `aeropass-app` ya existen; el DSN ya está en `env/*.env`.
- Métricas priorizadas por el usuario: de negocio, conversión de onboarding (esta app), auto rechazo (ambas apps) y autoservicio (backend); técnicas, disponibilidad (backend), latencia (backend, con el complemento de cliente de la Historia 5) y tasa de contingencia (backend, con los eventos de circuito/pinning de esta app).
- Enviar los eventos del embudo a Sentry no amplía lo que se recoge: son los mismos eventos, ya diseñados sin datos personales. El plan debe elegir la forma de envío (eventos, logs o métricas de Sentry) según lo que permita graficar tasas y p90 en el dashboard.
- El destinatario de cada correo lo define el usuario al crear la regla.
- La corrección del envío de datos personales por defecto sigue a la constitución (Principio VII, Governance), aunque antes se haya pedido mantenerlo activado.
- Session Replay se mantiene en toda la app por decisión del usuario (2026-09-23), apoyado en el enmascarado; el riesgo residual es que una pantalla nueva o un widget que el enmascarado no cubra quede grabado, y por eso FR-004 exige verificarlo antes de cada release.
- Este spec no cambia el comportamiento de ninguna pantalla.

### Recomendaciones adicionales

- **Release Health** (sesiones y usuarios libres de crash por versión) sale de la instrumentación existente y va en el dashboard sin trabajo adicional.
- **Scrubbing a nivel de proyecto** en `aeropass-app` ("Prevent storing of IP addresses" y reglas de Data Scrubbing) como segunda capa, además del filtro en la app.
