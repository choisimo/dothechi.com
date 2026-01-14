import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_interface.dart';

class MobileStorage implements StorageInterface {
  final FlutterSecureStorage _secureStorage;

  MobileStorage() : _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String? value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }
}
