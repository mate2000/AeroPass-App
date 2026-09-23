/// Why a request failed in transit (011-error-tecnico, research.md §2).
///
/// The data layer wraps transport errors in this type before returning
/// them in `Result.error`, so the presentation layer can tell the
/// passenger's connection from the service without knowing the HTTP
/// client. Errors that fit neither variant are returned unwrapped.
sealed class TransportFailure {
  const TransportFailure(this.cause);

  /// No connection reached the server.
  const factory TransportFailure.connectivity(Object cause) =
      ConnectivityFailure;

  /// The server was reached and failed, answered badly, or failed pinning.
  const factory TransportFailure.service(Object cause) = ServiceSideFailure;

  /// The original error, kept for local logging only. It never reaches an
  /// analytics event or an error report (Principle VII).
  final Object cause;

  @override
  String toString() => '$runtimeType';
}

final class ConnectivityFailure extends TransportFailure {
  const ConnectivityFailure(super.cause);
}

final class ServiceSideFailure extends TransportFailure {
  const ServiceSideFailure(super.cause);
}
