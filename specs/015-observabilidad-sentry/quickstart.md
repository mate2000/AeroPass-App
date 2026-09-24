# Quickstart: validar la observabilidad (App móvil)

**Feature**: 015 · Referencias: [plan.md](plan.md), [contracts/](contracts/)

Guía para comprobar de punta a punta que la feature funciona. No contiene código de implementación.

## Requisitos

- Flutter según `.fvmrc`; dependencias con `flutter pub get`.
- Acceso a la organización **Aeropass** en Sentry, proyecto `aeropass-app`.
- Para subir símbolos: variable `SENTRY_AUTH_TOKEN` en tu terminal o en el secreto del CI (nunca en el repo).

## §1 — Sin DSN no se envía nada

1. Ejecutar las pruebas: `flutter test`.
2. Esperado: todo en verde; ningún test envía a Sentry (los tests no cargan `env/*.env`).
3. Ejecutar la app sin `--dart-define-from-file`: funciona igual que antes; los eventos solo aparecen en el log local (`aeropass.analytics`).

## §2 — Filtro de privacidad (Historia 1)

1. Ejecutar las pruebas del filtro (unitarias, escritas primero): cubren las 6 garantías de [contracts/privacy-filter.md](contracts/privacy-filter.md).
2. En `dev`, provocar un crash de prueba (`SENTRY_SEND_TEST_EVENT=true`).
3. Esperado en Sentry: el evento no tiene sección *User*, no tiene IP y sus breadcrumbs solo muestran nombres de ruta.

## §3 — Eventos del embudo (Historia 2)

1. Prueba de contrato: la lista blanca de [contracts/telemetry-events.md](contracts/telemetry-events.md) coincide con las claves que emite el emisor (falla si alguien agrega una clave sin actualizar el contrato).
2. Con `env/dev.env`, recorrer bienvenida → consentimiento → captura.
3. Esperado en *Explore → Logs*, filtrando `aeropass.event:*`: un log por evento, con `aeropass.session_id`; desde `consent_confirmed` en adelante, también `aeropass.enrollment_attempt_id`. Ningún atributo fuera del contrato.
4. Modo avión durante un paso y reconectar: los logs de ese paso llegan después, sin que la app se haya detenido.

## §4 — Session Replay oculta todo lo sensible (FR-004, antes de cada release)

Grabar una sesión en `demo` que recorra estas pantallas y revisar la grabación en Sentry:

| Pantalla | Qué debe verse oculto |
|---|---|
| Captura de documento | Vista de la cámara |
| Confirmación de datos | Todos los textos de los campos |
| Instrucciones de selfie / liveness | Vista de la cámara, óvalo y marco de la selfie |
| Credencial activada | Textos |
| Pase | **El QR** (dibujado con `CustomPainter`) y los textos |

Si alguna muestra un dato, el release se bloquea hasta corregir la regla de ocultamiento.

## §5 — Métricas y dashboard (Historias 3–6)

1. Crear el dashboard y las reglas de [contracts/dashboard-and-alerts.md](contracts/dashboard-and-alerts.md) en la UI de Sentry, y configurar el proyecto (IP y Data Scrubbing).
2. Con `env/demo.env`: completar 3 registros; abandonar 1 en confirmación; cerrar la app a mitad de 1 y retomarlo hasta el final; forzar un rechazo de captura en el dispositivo.
3. Esperado con el filtro `demo`:
   - W3: 4 completados sobre 5 intentos = 80% (el retomado cuenta una sola vez).
   - W4: p90 calculado con los 3 registros completos sin reinicio (el retomado no aporta duración).
   - W5: el abandonado aparece en `confirmation_step_entered` y no en pasos posteriores.
   - W6: al menos un rechazo del dispositivo.
4. Regla A1: provocar el fallo del servicio de verificación en `demo`; esperado: correo en menos de 2 minutos. Luego poner `SENTRY_ALERT_RULE_CONFIRMED=true` en `env/demo.env` y comprobar que la pantalla de error técnico muestra "Nuestro equipo ya fue notificado".

## §6 — Preparar la presentación de 15 minutos (Historia 7, FR-018)

**Al menos 1 hora antes**, con `env/demo.env` (backends falsos, `SENTRY_ENVIRONMENT=demo`, muestreo al 100%):

1. Completar 10 registros de principio a fin.
2. Abandonar 3 en pasos distintos (captura, confirmación, liveness).
3. Retomar 1 tras cerrar la app.
4. Provocar 2 rechazos del dispositivo y 1 del backend.
5. Abrir el pase 3 veces con una credencial ya emitida.
6. Verificar que el dashboard con el filtro `demo` muestra cifras en W3–W10.

**En vivo (menos de 2 minutos por acción)**:
- Provocar el fallo del servicio de verificación → mostrar el correo de A1 y el evento en Sentry.
- Mostrar el dashboard filtrado por `demo`.
- Mostrar la configuración de A3 y A4, aclarando que evalúan solo prod por hora (no se dispararán en vivo).

## §7 — Símbolos de depuración (FR-017)

1. Compilar release con ofuscación y símbolos separados, y subirlos con `sentry_dart_plugin` (usa `SENTRY_AUTH_TOKEN` del entorno).
2. Provocar un crash en ese build.
3. Esperado: la pila en Sentry muestra nombres de función y líneas, no direcciones de memoria.
