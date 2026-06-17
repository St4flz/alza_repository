import 'dart:convert';
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

  Map<String, dynamic>? _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      String normalized = parts[1];
      switch (normalized.length % 4) {
        case 2:
          normalized += '==';
          break;
        case 3:
          normalized += '=';
          break;
      }
      final decodedBytes = base64Url.decode(normalized);
      final decodedString = utf8.decode(decodedBytes);
      return jsonDecode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[JWT DEBUG] Error decodificando JWT localmente: $e');
      return null;
    }
  }

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = Supabase.instance.client.auth.currentSession;
          debugPrint('================= DIO REQUEST START =================');
          debugPrint('URL: ${options.uri}');
          debugPrint('Method: ${options.method}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Payload: ${options.data}');
          }

          if (session != null && session.accessToken.isNotEmpty) {
            final token = session.accessToken;
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('[AUTH] Token JWT Completo enviado al backend:\n$token\n');

            // Decodificar el token para logging
            final decoded = _parseJwt(token);
            if (decoded != null) {
              debugPrint('[AUTH] Claims del JWT decodificado:');
              debugPrint('  - Issuer (iss): ${decoded['iss']}');
              debugPrint('  - Subject / User ID (sub): ${decoded['sub']}');
              debugPrint('  - Role (role): ${decoded['role']}');
              debugPrint('  - Email (email): ${decoded['email']}');
              
              if (decoded['exp'] != null) {
                final expSeconds = decoded['exp'] as int;
                final expDateTime = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
                final now = DateTime.now();
                final isExpired = now.isAfter(expDateTime);
                
                debugPrint('  - Expiration (exp): $expDateTime (Epoch: $expSeconds)');
                debugPrint('  - Local Current Time: $now');
                if (isExpired) {
                  debugPrint('  ⚠️⚠️⚠️ ALERTA: ¡EL TOKEN JWT HA EXPIRADO LOCALMENTE! ⚠️⚠️⚠️');
                } else {
                  final remaining = expDateTime.difference(now);
                  debugPrint('  - Tiempo restante de validez: ${remaining.inMinutes} minutos');
                }
              }
            } else {
              debugPrint('[AUTH] ⚠️ No se pudo decodificar el payload del JWT.');
            }
          } else {
            debugPrint('[AUTH] ⚠️ No se encontró una sesión activa de Supabase en el cliente.');
          }
          debugPrint('================= DIO REQUEST END ===================');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('================= DIO RESPONSE START =================');
          debugPrint('Status: ${response.statusCode}');
          debugPrint('URL: ${response.requestOptions.uri}');
          debugPrint('Headers: ${response.headers.map}');
          debugPrint('Data: ${response.data}');
          debugPrint('================= DIO RESPONSE END ===================');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint('================= DIO ERROR START ===================');
          debugPrint('URL: e.requestOptions.uri: ${e.requestOptions.uri}');
          debugPrint('Method: ${e.requestOptions.method}');
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Message: ${e.message}');
          debugPrint('Response Headers: ${e.response?.headers.map}');
          debugPrint('Response Data: ${e.response?.data}');
          debugPrint('================= DIO ERROR END =====================');
          
          if (e.response?.statusCode == 401) {
            debugPrint('[AUTH] ⚠️ HTTP 401 recibido! Cerrando sesión local en Supabase...');
            await Supabase.instance.client.auth.signOut();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
