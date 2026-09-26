# Inyección de fallos en la app (build `chaos`)

Guía para provocar fallos reales desde la app y comprobar que la observabilidad reacciona como se espera (anexo de inyección de fallos, niveles N1/N2). Contrato de la telemetría: [contracts/telemetry-events.md](contracts/telemetry-events.md) §5 y §6.

## Qué hay en la app

- **Build `chaos`**: `env/chaos.env` y la configuración de VS Code "aeropass_app (chaos, fault injection)".
  - Etiqueta Sentry como entorno `chaos`, con muestreo al 100 %.
  - Muestra el botón ⚡ (panel de fallos) en todas las pantallas.
  - Un release se niega a arrancar con `CHAOS_TOOLS`, y `tool/check_release_env.dart` lo rechaza.
- **Panel ⚡**:
  - **Red (lado del teléfono)**: latencia (2, 5 o 12 s); timeout (espera el límite real de la petición); sin conexión; 500; 503 `ALMACENAMIENTO_NO_DISPONIBLE`; 504 (corte de Vercel); 401 `NO_AUTENTICADO`; 429 `LIMITE_EMISION_EXCEDIDO`.
  - **Alcance**: todo, identidad, biometría o pases.
  - **Fallo pedido al backend**: header `X-AeroPass-Fault` (más `X-AeroPass-Fault-Key` si el Preview tiene secreto). Lo implementa la spec 003 del backend (rama `feature/003-fault-injection`), solo en un Preview con `FAULT_INJECTION_ENABLED=true`. El backend confirma con `X-AeroPass-Fault-Applied`.
  - **Error no controlado** (alimenta crash-free y la alerta A2) y **crash nativo** (la app se cierra y el reporte llega al reabrirla).
- **Cómo inyecta**: `FaultInjectionInterceptor` va **primero** en la cadena de Dio, así que un fallo inyectado pasa por el `AuthInterceptor` real (reintento silencioso ante 401) y por el `DiagnosticsInterceptor` real. Pantallas, reintentos y telemetría reaccionan igual que ante el fallo verdadero.
- **Marcado**: mientras haya un fallo activo, cada log de diagnóstico lleva `aeropass.diag.fault_injected=true` y `aeropass.diag.fault`, y cada evento de Sentry la etiqueta `fault_injected`. Así se separa lo inyectado de un incidente real.

## Antes de empezar

1. **Backend aislado**: para fallos del backend, apuntar `API_BASE_URL` de `env/chaos.env` a un **Preview de Vercel**, con su propia rama de Neon, su propio Upstash y su propio Blob. Si el Preview tiene Deployment Protection, poner su secreto en `VERCEL_PROTECTION_BYPASS`. Los fallos del lado del teléfono solo afectan a ese teléfono, así que se pueden probar contra cualquier backend.
2. **Filtrar los tableros por el entorno `chaos`**. A3, A4 y B2 solo miran `prod`, así que no se disparan. A1, A2, B1 y B3 se disparan en todos los entornos: avisar al equipo de que llegarán correos.
3. **Estado estable**: 15 minutos de uso normal (registros completos), anotando los valores de los widgets.

## Experimentos

Escribir la hipótesis antes de inyectar; después repetir el flujo 3–5 veces, observar, limpiar (panel → Limpiar) y comprobar que todo vuelve al estado estable.

| Fallo | Cómo | Esperado en la app (Sentry Logs / pantallas) | Esperado en tableros y alertas |
|---|---|---|---|
| Almacenamiento caído en la selfie | Red: 503 Blob · Alcance: Biometría | `selfie_verification code=blobStorage`, `verification_failed target=technicalError`, pantalla de error técnico | W11 con `failure_class:service`, **A1** |
| Vercel corta la función | Red: 504 · Alcance: Biometría | `selfie_verification code=backendFunctionTimeout` | W11, **A1** |
| Selfie lenta | Red: Latencia 12 s · Alcance: Biometría | `biometric_verify ms` alto; aviso "Seguir esperando" a los 10 s | W9 (pantalla de verificación más lenta) |
| Timeout real de la selfie | Red: Timeout · Alcance: Biometría | La pantalla de verificación corta a los 30 s: `verification_failed kind=timedOut` | W11 |
| Sin conexión | Red: Sin conexión | `backend_http_error type=connectionError`, `failure_class=connectivity` | W11 (clase `connectivity`, no dispara A1) |
| Sesión inválida | Red: 401 sesión | Un reintento silencioso, `session_ended`, vuelta a `/sign-in` | — |
| Límite de emisión | Red: 429 límite · Alcance: Pases | Error al emitir el pase | — |
| Pase lento | Red: Latencia 5 s · Alcance: Pases | Pase listo más tarde | W10 (tiempo hasta el pase utilizable) |
| `/me` lento en el arranque | Red: Latencia 12 s · Alcance: Identidad | `redirect_step` con `ms` alto; "Iniciando sesión…" más tiempo | W9 |
| Error no controlado | Botón "Error no controlado" | Evento no controlado en Issues | W1/W2 (crash-free), **A2** si baja de 99 % en la hora |
| Crash nativo | Botón "Crash nativo" (reabrir la app) | Crash nativo en Issues | W1/W2, **A2** |
| Fallos del backend | Fallo pedido al backend (tabla siguiente) | Según el fallo | Tablero del backend: evento `fault.injected` y W5, W7, W8, W10, W11; B1, B3 |

### Fallos pedidos al backend (spec 003 del backend)

| Fallo | Respuesta del backend (verificada por sus tests) | Esperado en la app |
|---|---|---|
| `blob_down` (alcance Biometría o Identidad) | `503 ALMACENAMIENTO_NO_DISPONIBLE` | `selfie_verification code=blobStorage`, error técnico, **A1** |
| `mxface_down` / `mxface_quota` | `200 NO_CONCLUYENTE`, sin gastar intento | `selfie_verification code=inconclusive`, error técnico; 5 seguidos abren el breaker → **B3** |
| `mxface_slow:12000` | `NO_CONCLUYENTE` al superar el timeout del proveedor | `inconclusive` después de ~12 s |
| `redis_down` (alcance Pases) | `503 ALMACENAMIENTO_NO_DISPONIBLE`: el pase no se emite sin registrar su token | Error al emitir el pase |
| `qstash_down` | Sin cambio (`EXITOSO`) | Flujo normal: comprueba que QStash no bloquea |
| `db_down` | Hoy error no controlado (500): **hallazgo** en el backend | `backend_http_error status=500`; **B1** en el backend |
| `signing_down` (alcance Pases) | Hoy error no controlado (500): **hallazgo** en el backend | Error al emitir el pase; **B1** en el backend |

## Registro de resultados

Por experimento: hipótesis, fecha, número de repeticiones, valores observados (widgets y logs con su `code`), alertas recibidas y tiempo hasta cada una, y conclusión (confirmada o hallazgo). Un hallazgo típico: un fallo que debería ser controlado aparece como no controlado (B1/A2), o una señal esperada que no aparece (hueco de observabilidad).
