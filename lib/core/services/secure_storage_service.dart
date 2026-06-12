import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  Future<bool> write({required String key, required String value}) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to write to secure storage',
        error: e,
        stackTrace: stackTrace,
        name: 'SecureStorageService',
      );
      return false;
    }
  }

  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to read from secure storage',
        error: e,
        stackTrace: stackTrace,
        name: 'SecureStorageService',
      );
      return null;
    }
  }

  Future<bool> delete({required String key}) async {
    try {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete from secure storage',
        error: e,
        stackTrace: stackTrace,
        name: 'SecureStorageService',
      );
      return false;
    }
  }

  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to check key existence in secure storage',
        error: e,
        stackTrace: stackTrace,
        name: 'SecureStorageService',
      );
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      await _storage.deleteAll(
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to clear secure storage',
        error: e,
        stackTrace: stackTrace,
        name: 'SecureStorageService',
      );
      return false;
    }
  }
}
