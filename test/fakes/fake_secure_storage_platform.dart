import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';

/// An in-memory `FlutterSecureStoragePlatform` double used to back the
/// "real" `CredentialRepositoryImpl` in the contract test suite without a
/// device Keystore/Keychain. Extends (rather than implements) the platform
/// interface, per its own documented guidance, so the plugin-interface
/// verification token is set correctly.
class FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final Map<String, String> _store = {};

  void seed(Map<String, String> values) => _store.addAll(values);

  void clearAll() => _store.clear();

  /// When set, every [write] throws it (008: storage-write failure cases).
  Object? writeError;

  /// When set, every [delete] throws it (008: withdrawal clear failure).
  Object? deleteError;

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    final error = writeError;
    if (error != null) throw error;
    _store[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => _store[key];

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => _store.containsKey(key);

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    final error = deleteError;
    if (error != null) throw error;
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => Map.of(_store);

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _store.clear();
  }
}
