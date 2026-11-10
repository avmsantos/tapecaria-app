import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Guarda o token de login no armazenamento seguro do aparelho.
class StorageService extends GetxService {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  String? token;

  Future<StorageService> init() async {
    token = await _secure.read(key: 'token');
    return this;
  }

  Future<void> saveToken(String value) async {
    token = value;
    await _secure.write(key: 'token', value: value);
  }

  Future<void> clear() async {
    token = null;
    await _secure.delete(key: 'token');
  }
}
