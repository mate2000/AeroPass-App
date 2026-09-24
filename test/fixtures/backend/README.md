# Backend contract fixtures (015 T009)

These are shapes copied from the backend source, not recorded traffic:

- source: `AirPass/Aeropass`, commit `d6eb85483551377fa744aa958b771664302b648d` (2026-09-23);
- `src/aeropass/api/schemas.py` gives the response models;
- `src/aeropass/domain/errors.py` gives each `codigo` and its HTTP status;
- `src/aeropass/main.py` gives the error body and the `Retry-After` header.

The `error_*.json` files wrap a body with its status and the `Retry-After` a real response
carries. Every `mensaje` is the sentinel `MENSAJE_INTERNO_NO_MOSTRAR`, which the wording test
asserts never reaches a screen (FR-007).

When the backend changes a schema, update these files from the new source and record the new
commit here. `backend_api_contract_test.dart` then shows exactly which app mapping breaks.
