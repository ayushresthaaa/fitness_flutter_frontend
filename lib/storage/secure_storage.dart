import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//though the AuthProvider is already using FlutterSecureStorage, this class can be used for other secure storage needs in the app, such as storing user preferences, tokens for other services, etc. It provides a simple interface for writing, reading, and deleting data securely.
class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }
}
