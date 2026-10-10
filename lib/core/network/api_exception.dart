import 'package:dio/dio.dart';

/// Server ke error ko user-friendly message me badalta hai.
class ApiException implements Exception {
  const ApiException(this.message);

  factory ApiException.from(DioException e) {
    final status = e.response?.statusCode;
    if (status == null) {
      return const ApiException(
        'Cannot reach the server. Check your connection and try again.',
      );
    }
    if (status == 429) {
      return const ApiException(
        'Too many attempts. Please wait a minute and try again.',
      );
    }
    if (status >= 500) {
      return const ApiException('The server had a problem. Please try again.');
    }
    return ApiException(
      _serverMessage(e.response?.data) ??
          'Something went wrong. Please try again.',
    );
  }

  final String message;

  static String? _serverMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
      if (message is List) return message.join('\n');
    }
    return null;
  }

  @override
  String toString() => message;
}