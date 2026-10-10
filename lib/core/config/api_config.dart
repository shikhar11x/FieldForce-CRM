import 'dart:io' show Platform;

abstract final class ApiConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');

  /// Android emulator me computer ka localhost `10.0.2.2` hota hai.
  /// Asli phone ke liye: --dart-define=API_BASE_URL=http://PC-IP:3000/api/v1
  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    return Platform.isAndroid
        ? 'http://10.0.2.2:3000/api/v1'
        : 'http://localhost:3000/api/v1';
  }

  /// --dart-define=USE_MOCK_AUTH=true se purane mock login pe wapas.
  static const useMockAuth = bool.fromEnvironment('USE_MOCK_AUTH');
}