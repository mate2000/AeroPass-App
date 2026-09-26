import 'package:sentry_flutter/sentry_flutter.dart';

/// The single privacy gate every Sentry output passes through
/// (015 contracts/privacy-filter.md, Constitution Principle VII).
///
/// Logs and metrics use an allowlist: an `aeropass.*` attribute reaches
/// Sentry only if contracts/telemetry-events.md names it, so a new field
/// needs a contract change before it can leave the device.
final class SentryPrivacyFilter {
  const SentryPrivacyFilter({required this.alertEventTag});

  /// The tag of 011's operational alert event, which carries no breadcrumbs
  /// at all (011 research §7).
  final String alertEventTag;

  /// Attributes every funnel log carries (contracts/telemetry-events.md §1).
  static const Set<String> logEnvelopeAttributes = {
    eventAttribute,
    'aeropass.session_id',
    'aeropass.enrollment_attempt_id',
  };

  /// Payload attributes, one per `LoggingAnalyticsEmitter` payload key in
  /// snake_case (contracts/telemetry-events.md §1). Kept in step with the
  /// emitter by test/contract/telemetry_allowlist_contract_test.dart.
  static const Set<String> logPayloadAttributes = {
    'aeropass.arrival',
    'aeropass.attempt_number',
    'aeropass.channel',
    'aeropass.chat_available',
    'aeropass.checkpoint',
    'aeropass.confirmed',
    'aeropass.credential_confirmed',
    'aeropass.destination',
    'aeropass.document_scan',
    'aeropass.elapsed_seconds',
    'aeropass.failure_class',
    'aeropass.field',
    'aeropass.has_next_trip',
    'aeropass.has_prior_record',
    'aeropass.issuance',
    'aeropass.job_terminal',
    'aeropass.kind',
    'aeropass.live',
    'aeropass.module_available',
    'aeropass.offline_capable',
    'aeropass.outcome',
    'aeropass.permanent',
    'aeropass.phase_index',
    'aeropass.reason',
    'aeropass.route',
    'aeropass.row_count',
    'aeropass.seconds_since_opened',
    'aeropass.selfie',
    'aeropass.stage',
    'aeropass.state',
    'aeropass.status',
    'aeropass.succeeded',
    'aeropass.text_version_id',
    'aeropass.total_phases',
    'aeropass.variant',
    'aeropass.within_window',
  };

  /// Metrics allowed to leave the device, with their allowed attributes
  /// (contracts/telemetry-events.md §2).
  static const Map<String, Set<String>> metricAttributes = {
    'enrollment.duration': {'aeropass.resumed'},
  };

  static const String eventAttribute = 'aeropass.event';

  /// Operational diagnostics (`Diagnostics`, contracts/telemetry-events.md
  /// §4): codes, states, paths, sizes and durations, redacted before they
  /// are sent, and never a personal datum by construction.
  static const String diagnosticsAttributePrefix = 'aeropass.diag.';

  /// Attributes the SDK adds itself that identify no one: environment,
  /// release, SDK, OS and device model. `user.*` is never kept.
  static const Set<String> _sdkAttributePrefixes = {
    'sentry.',
    'os.',
    'device.',
    'app.',
  };

  static const Set<String> _passThroughBreadcrumbCategories = {
    // `Diagnostics` breadcrumbs carry the same redacted data as its logs.
    'diagnostics',
    'app.lifecycle',
    'ui.lifecycle',
    'device.connectivity',
    'device.orientation',
    'device.event',
  };

  static const Set<String> _navigationDataKeys = {'state', 'from', 'to'};
  static const Set<String> _httpDataKeys = {'url', 'method', 'status_code'};

  SentryEvent? beforeSend(SentryEvent event, Hint hint) => _scrub(event);

  SentryTransaction? beforeSendTransaction(
    SentryTransaction transaction,
    Hint hint,
  ) => _scrub(transaction);

  Breadcrumb? beforeBreadcrumb(Breadcrumb? breadcrumb, Hint hint) =>
      breadcrumb == null ? null : _filterBreadcrumb(breadcrumb);

  SentryLog? beforeSendLog(SentryLog log) {
    final eventName = log.attributes[eventAttribute]?.value;
    if (eventName is! String || eventName != log.body) return null;
    log.attributes.removeWhere((key, _) => !_isAllowedLogAttribute(key));
    return log;
  }

  SentryMetric? beforeSendMetric(SentryMetric metric) {
    final allowed = metricAttributes[metric.name];
    if (allowed == null) return null;
    metric.attributes.removeWhere(
      (key, _) => !allowed.contains(key) && !_isSdkAttribute(key),
    );
    return metric;
  }

  T _scrub<T extends SentryEvent>(T event) {
    final isAlert = event.tags?.containsKey(alertEventTag) ?? false;
    event
      ..user = null
      ..request = null
      ..breadcrumbs = isAlert
          ? null
          : event.breadcrumbs
                ?.map(_filterBreadcrumb)
                .whereType<Breadcrumb>()
                .toList();
    event.contexts.device?.name = null;
    return event;
  }

  Breadcrumb? _filterBreadcrumb(Breadcrumb breadcrumb) {
    final category = breadcrumb.category;
    if (category == 'navigation') {
      return breadcrumb..data = _keep(breadcrumb.data, _navigationDataKeys);
    }
    if (category == 'http') {
      final data = _keep(breadcrumb.data, _httpDataKeys);
      final url = data?['url'];
      if (url is String) data!['url'] = _withoutQuery(url);
      return breadcrumb..data = data;
    }
    return _passThroughBreadcrumbCategories.contains(category)
        ? breadcrumb
        : null;
  }

  bool _isAllowedLogAttribute(String key) =>
      logEnvelopeAttributes.contains(key) ||
      logPayloadAttributes.contains(key) ||
      key.startsWith(diagnosticsAttributePrefix) ||
      _isSdkAttribute(key);

  bool _isSdkAttribute(String key) => _sdkAttributePrefixes.any(key.startsWith);

  static Map<String, dynamic>? _keep(
    Map<String, dynamic>? data,
    Set<String> keys,
  ) => data == null
      ? null
      : {
          for (final entry in data.entries)
            if (keys.contains(entry.key)) entry.key: entry.value,
        };

  /// Keeps scheme, host, port and path; drops the query, the fragment and
  /// any credentials in the URL.
  static String _withoutQuery(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) {
      return url.split(RegExp('[?#]')).first;
    }
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: uri.path,
    ).toString();
  }
}
