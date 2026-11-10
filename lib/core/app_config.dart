class AppConfig {
  /// Endereço da API. Emulador Android acessa o PC em 10.0.2.2.
  /// Em celular real use o IP do PC:
  ///   flutter run --dart-define=API_URL=http://192.168.0.10:8000/api
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
