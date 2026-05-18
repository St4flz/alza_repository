import 'package:dio/dio.dart';
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
          if (session != null && session.accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Manejo global de errores (ej. token expirado, no autorizado)
          if (e.response?.statusCode == 401) {
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
