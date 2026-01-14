import 'package:flutter/foundation.dart' show kIsWeb;
import 'storage_interface.dart';
import 'web_storage.dart';
import 'mobile_storage.dart';

class StorageFactory {
  static StorageInterface create() {
    if (kIsWeb) {
      return WebStorage();
    }
    return MobileStorage();
  }
}
