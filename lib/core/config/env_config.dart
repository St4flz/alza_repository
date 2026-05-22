import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey => dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  
  // Nota de seguridad: La clave secreta NUNCA debe ser expuesta ni usada en el frontend de forma pública.
  static String get supabaseSecretKey => dotenv.env['SUPABASE_SECRET_KEY'] ?? '';
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
}
