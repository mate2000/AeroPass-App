import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/identity_record.dart';

/// Wraps the two external data sources `IdentityRecordRepositoryImpl` needs
/// (Constitution Principle VIII): a certificate-pinned `dio` client for the
/// confirmation submission, and `flutter_secure_storage` for the
/// display-only local cache (research.md §5) — the one new persisted-state
/// category this feature introduces, already named in the Constitution's
/// Principle I allowlist.
///
/// Constructor-injected (Principle IX). Any transport failure is left to
/// throw — mapping that into `Result.error` is
/// `IdentityRecordRepositoryImpl`'s job, at the service boundary.
class IdentityRecordService {
  IdentityRecordService({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _dio = dio,
       _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String displaySubsetKey =
      'aeropass.identity_record.display_subset';

  /// POSTs the full record — every field's value, source, and (for a
  /// corrected field) its original value and whether it was automatically
  /// re-verified. Throws on any transport failure; a backend rejection of a
  /// well-formed record is also left to throw (non-2xx), mapped to
  /// `Result.error` by the repository, per FR-017.
  Future<void> submit(IdentityRecord record) async {
    await _dio.post<Map<String, dynamic>>(
      '/v1/identity-record',
      data: {
        'fields': [
          for (final field in record.fields)
            {
              'key': _wireKeyFor(field.key),
              'value': field.value,
              'source': field.source.name,
              if (field.originalValue != null)
                'originalValue': field.originalValue,
              'reverified': field.reverified,
            },
        ],
      },
    );
  }

  /// Writes exactly the display-only subset — key+value pairs, nothing else
  /// — to secure storage. Called only after [submit] has succeeded.
  Future<void> writeDisplaySubset(IdentityRecord record) async {
    final subset = {
      for (final field in record.fields) field.key.name: field.value,
    };
    await _secureStorage.write(
      key: displaySubsetKey,
      value: jsonEncode(subset),
    );
  }

  /// Reads back the display-only subset as written by [writeDisplaySubset],
  /// or an empty map if nothing has ever been written. Exposed for the
  /// contract test suite's assertion on what actually got cached (research.md
  /// §5) — a later feature (the credential/pass surfaces) is the intended
  /// production reader of this same value.
  Future<Map<String, String>> readDisplaySubsetForTesting() async {
    final raw = await _secureStorage.read(key: displaySubsetKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  String _wireKeyFor(FieldKey key) => switch (key) {
    FieldKey.fullName => 'full_name',
    FieldKey.documentNumber => 'document_number',
    FieldKey.nationality => 'nationality',
    FieldKey.expiryDate => 'expiry_date',
  };
}
