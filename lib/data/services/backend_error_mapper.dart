import 'package:dio/dio.dart';

import '../../domain/entities/backend_error.dart';
import '../../domain/entities/session_state.dart';
import 'transport_error_mapper.dart';

/// Maps a failed request to the domain (015 research.md §12):
///
/// - a response from the backend becomes a [BackendError], whose `mensaje`
///   is dropped here, unread;
/// - no session token becomes [SessionUnavailable] (FR-001);
/// - anything else goes through [mapTransportError], so the connection and
///   the service stay distinguishable (011).
Object mapBackendError(Object error) {
  if (error is DioException) {
    if (error.error is SessionUnavailable) return error.error!;
    final response = error.response;
    if (response != null && response.statusCode != null) {
      return _fromResponse(response);
    }
  }
  return mapTransportError(error);
}

BackendError _fromResponse(Response<dynamic> response) {
  final body = response.data;
  final codigo = body is Map ? body['codigo'] : null;
  final detalles = body is Map ? body['detalles'] : null;
  final campos = detalles is Map ? detalles['campos'] : null;
  return BackendError(
    code: BackendErrorCode.fromWire(codigo),
    status: response.statusCode!,
    retryAfter: _retryAfter(response.headers.value('retry-after')),
    fields: [
      if (campos is List)
        for (final campo in campos)
          if (campo is String) campo,
    ],
  );
}

/// The backend sends whole seconds (`main.py`). An HTTP-date or anything
/// unparseable is ignored rather than guessed.
Duration? _retryAfter(String? header) {
  final seconds = int.tryParse(header?.trim() ?? '');
  if (seconds == null || seconds < 0) return null;
  return Duration(seconds: seconds);
}
