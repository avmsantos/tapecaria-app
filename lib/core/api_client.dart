import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.status});

  final String message;
  final int? status;

  factory ApiException.from(Object e, [StackTrace? stack]) {
    if (e is ApiException) return e;

    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status != null && status >= 500) {
        return ApiException('Erro no servidor. Tente novamente em instantes.', status: status);
      }

      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return ApiException(first.first.toString(), status: status);
          }
        }
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) {
          return ApiException(msg, status: status);
        }
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return ApiException('Sem conexão com o servidor. Verifique a internet.');
        default:
          return ApiException('Não foi possível falar com o servidor.', status: status);
      }
    }

    debugPrint('Erro inesperado: $e\n$stack');
    if (kDebugMode) return ApiException('Erro inesperado (${e.runtimeType}): $e');
    return ApiException('Erro inesperado.');
  }

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._storage) {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.token;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) onUnauthorized?.call();
        handler.next(error);
      },
    ));
  }

  final StorageService _storage;
  late final Dio dio;

  /// Chamado quando o servidor responde 401 (token inválido ou expirado).
  void Function()? onUnauthorized;

  /// Executa uma chamada e converte erros do Dio em ApiException.
  Future<T> run<T>(Future<T> Function(Dio dio) action) async {
    try {
      return await action(dio);
    } catch (e, stack) {
      throw ApiException.from(e, stack);
    }
  }
}
