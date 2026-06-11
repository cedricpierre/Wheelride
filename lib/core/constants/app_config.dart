import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _env(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key] ?? '';
  }

  static String get supabaseUrl => _env('SUPABASE_URL');
  static String get supabasePublishableKey => _env('SUPABASE_PUBLISHABLE_KEY');
  static String get mapTilerKey => _env('MAPTILER_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String get tileUrlTemplate {
    if (mapTilerKey.isEmpty) {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }

    return 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey';
  }
}
