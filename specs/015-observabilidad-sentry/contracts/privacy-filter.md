# Contrato: filtro central de privacidad (`SentryPrivacyFilter`)

**Feature**: 015 · Referencias: [research.md](../research.md) §5–§6 · FR-002, FR-003, FR-004 · Historia 1

Un solo componente, conectado a todos los puntos de salida del SDK. Es código de frontera de confianza para la privacidad: sus pruebas se escriben primero (Principio IV, por analogía con la clasificación de datos que protege).

| Punto de salida del SDK | Qué hace el filtro |
|---|---|
| Opciones globales | `sendDefaultPii = false`; `attachScreenshot = false` (se conserva de 011) |
| `beforeSend` (errores y crashes) | Elimina `user`, `request` y la IP; elimina de `extra`/`contexts` cualquier clave fuera de una lista mínima técnica (dispositivo, SO, app, cultura); filtra breadcrumbs con la misma regla que `beforeBreadcrumb`. Reemplaza a `stripAlertEventPii`. |
| `beforeSendTransaction` (trazas) | Elimina `user` y `request`; conserva nombres de ruta y spans del SDK; elimina datos de spans HTTP que incluyan query o cuerpo. |
| `beforeBreadcrumb` | Conserva: navegación (solo nombre de ruta, sin `extra`), ciclo de vida de la app, conectividad. Descarta: consola/`print`, entrada de texto, HTTP con query o cuerpo. |
| `beforeSendLog` | Lista blanca de atributos de [telemetry-events.md](telemetry-events.md) §1; elimina `user.*`; el cuerpo del mensaje debe ser igual a `aeropass.event` (si no, el log se descarta). |
| `beforeSendMetric` | Solo métricas nombradas en [telemetry-events.md](telemetry-events.md) §2, con sus atributos permitidos; cualquier otra se descarta. |

## Session Replay (FR-004)

- Se mantiene el ocultamiento por defecto de textos e imágenes y `mask<CameraPreview>()` (011).
- Se agregan reglas explícitas para los widgets dibujados con `CustomPainter` que muestran datos del pasajero o del pase: el QR (`qr_code_painter.dart`) y las vistas de selfie y liveness (`selfie_frame_preview.dart`, `liveness_oval_overlay.dart`). Ver research §6.

## Garantías que prueban los tests

1. Un evento con `user`, IP o `request` sale sin ellos.
2. Un log con un atributo fuera de la lista blanca sale sin ese atributo.
3. Un log cuyo mensaje no coincide con `aeropass.event` no sale.
4. Una métrica no listada no sale.
5. Un breadcrumb de consola o de entrada de texto no sale; uno de navegación sale sin `extra`.
6. El evento `verification_service_failure` de 011 sigue saliendo con sus etiquetas y sin usuario (no regresión).
