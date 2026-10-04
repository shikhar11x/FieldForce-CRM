import 'dart:async';

import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Dio wrapper: token attach karta hai, 401 pe ek baar refresh karke request
/// dohra deta hai. Refresh ek time pe ek hi chalta hai, kyunki backend
/// purane refresh token ka dobara use hone par poora session band kar deta hai.
class ApiClient {
  ApiClient({required String baseUrl, required this.tokens})
      : dio = Dio(_options(baseUrl)),
        _refreshDio = Dio(_options(baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  /// Is flag wali requests pe token nahi lagta aur 401 pe refresh nahi hota.
  static final skipAuth = Options(extra: {'skipAuth': true});

  final Dio dio;
  final TokenStorage tokens;

  // Alag instance, interceptors ke bina, taaki refresh khud refresh na kare.
  final Dio _refreshDio;
  final _expired = StreamController<void>.broadcast();
  Future<bool>? _refreshing;

  /// Refresh fail ho jaye (session khatam) to event aata hai.
  Stream<void> get onSessionExpired => _expired.stream;

  static BaseOptions _options(String baseUrl) => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      );

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] != true) {
      final token = await tokens.accessToken;
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final canRefresh = error.response?.statusCode == 401 &&
        request.extra['skipAuth'] != true &&
        request.extra['retried'] != true;

    if (!canRefresh || !await _refreshTokens()) {
      return handler.next(error);
    }

    try {
      request.extra['retried'] = true;
      handler.resolve(await dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await tokens.refreshToken;
    if (refreshToken == null) {
      _expireSession();
      return false;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data!;
      await tokens.save(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Server ne token reject kiya: session khatam. Network error ho to
      // session rehne do, baad me dobara try hoga.
      if (status == 401 || status == 403) _expireSession();
      return false;
    }
  }

  void _expireSession() {
    unawaited(tokens.clear());
    _expired.add(null);
  }

  void dispose() => _expired.close();
}