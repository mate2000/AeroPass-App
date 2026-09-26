import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sentry_flutter/sentry_flutter.dart';

import '../data/services/sentry_privacy_filter.dart';
import 'fault_injection.dart';

/// Operational diagnostics that can be read in production: Sentry Logs (and
/// a Sentry breadcrumb, so the trail rides along with any later event), plus
/// the device log (`adb logcat -s flutter`). With no Sentry DSN only the
/// device log is written.
///
/// What goes in: event names, error codes, statuses, HTTP methods, paths
/// (without the query), status codes and durations. What never goes in: an
/// email, a name, a document number, a code the passenger typed, a token, a
/// header or a request body (015 FR-017). Every value passes through
/// [redactDiagnostic] as a second line of defence.
class Diagnostics {
  const Diagnostics();

  void info(String event, [Map<String, Object?> attributes = const {}]) =>
      _emit(SentryLogLevel.info, SentryLevel.info, event, attributes);

  void warn(String event, [Map<String, Object?> attributes = const {}]) =>
      _emit(SentryLogLevel.warn, SentryLevel.warning, event, attributes);

  /// A failure worth an issue in Sentry: also captured as a message, grouped
  /// by [event] and the `code` attribute.
  void error(String event, [Map<String, Object?> attributes = const {}]) {
    final clean = _emit(
      SentryLogLevel.error,
      SentryLevel.error,
      event,
      attributes,
    );
    if (!Sentry.isEnabled) return;
    unawaited(
      Sentry.captureMessage(
        event,
        level: SentryLevel.error,
        withScope: (scope) {
          scope.fingerprint = [event, clean['code'] ?? ''];
          for (final MapEntry(:key, :value) in clean.entries) {
            unawaited(scope.setTag(key, _tagValue(value)));
          }
        },
      ),
    );
  }

  Map<String, String> _emit(
    SentryLogLevel logLevel,
    SentryLevel level,
    String event,
    Map<String, Object?> attributes,
  ) {
    final clean = <String, String>{
      for (final MapEntry(:key, :value) in attributes.entries)
        if (value != null && '$value'.isNotEmpty)
          // A number (a size, a duration, a status) is never personal data,
          // and masking its digits would hide it.
          key: value is num ? '$value' : redactDiagnostic('$value'),
      // A chaos build marks everything logged while a fault is active, so an
      // injected failure is never mistaken for a real incident (§6).
      if (FaultInjection.instance.active) ...{
        'fault_injected': 'true',
        'fault': FaultInjection.instance.label,
      },
    };
    debugPrint(
      '[aeropass] ${logLevel.name} $event '
      '${clean.entries.map((e) => '${e.key}=${e.value}').join(' ')}',
    );
    if (Sentry.isEnabled) {
      // Shaped for SentryPrivacyFilter.beforeSendLog: `aeropass.event` equal
      // to the body, and the attributes under the `aeropass.diag.*`
      // namespace, which contracts/telemetry-events.md §4 allows. The values
      // were already redacted above.
      final attrs = {
        SentryPrivacyFilter.eventAttribute: SentryAttribute.string(event),
        for (final MapEntry(:key, :value) in clean.entries)
          '${SentryPrivacyFilter.diagnosticsAttributePrefix}$key':
              SentryAttribute.string(value),
      };
      unawaited(
        Future.sync(
          () => switch (logLevel) {
            SentryLogLevel.error => Sentry.logger.error(
              event,
              attributes: attrs,
            ),
            SentryLogLevel.warn => Sentry.logger.warn(event, attributes: attrs),
            _ => Sentry.logger.info(event, attributes: attrs),
          },
        ),
      );
      unawaited(
        Sentry.addBreadcrumb(
          Breadcrumb(
            category: 'diagnostics',
            message: event,
            level: level,
            data: clean,
          ),
        ),
      );
    }
    return clean;
  }

  // Sentry tag values are limited to 200 characters.
  static String _tagValue(String value) =>
      value.length <= 200 ? value : value.substring(0, 200);
}

final _email = RegExp(r'[^\s@<>"]+@[^\s@<>"]+\.[^\s@<>"]+');
final _jwt = RegExp(r'eyJ[\w-]+\.[\w-]+\.[\w-]*');
final _bearer = RegExp(r'Bearer\s+\S+', caseSensitive: false);
final _longDigits = RegExp(r'\d{6,}');
const _maxValueLength = 500;

/// Masks what must never reach a log: email addresses, JWTs, bearer values
/// and runs of six or more digits (a document number or a typed code).
/// Long values are cut.
String redactDiagnostic(String value) {
  final masked = value
      .replaceAll(_jwt, '<jwt>')
      .replaceAll(_bearer, 'Bearer <redacted>')
      .replaceAll(_email, '<email>')
      .replaceAll(_longDigits, '<digits>');
  return masked.length <= _maxValueLength
      ? masked
      : '${masked.substring(0, _maxValueLength)}…';
}
