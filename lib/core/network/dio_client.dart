import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alza/core/config/env_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Obtener el access token de Supabase
          final session = Supabase.instance.client.auth.currentSession;
          debugPrint('--- Dio REQUEST ---');
          debugPrint('URL: ${options.uri}');
          debugPrint('Method: ${options.method}');
          if (session != null && session.accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
            debugPrint('Authorization: Bearer ${session.accessToken.substring(0, 10)}...');
          } else {
            debugPrint('No Supabase session found!');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('--- Dio RESPONSE ---');
          debugPrint('Status: ${response.statusCode}');
          debugPrint('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint('--- Dio ERROR ---');
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Message: ${e.message}');
          debugPrint('Response Data: ${e.response?.data}');
          // Manejo global de errores (ej. token expirado, no autorizado)
          if (e.response?.statusCode == 401) {
            debugPrint('Unauthorized! Force signing out of Supabase...');
            // Limpiar sesión local de Supabase
            await Supabase.instance.client.auth.signOut();
            // TODO: Redirigir a la pantalla de login mediante router global o event bus
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
