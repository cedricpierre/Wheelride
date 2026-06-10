class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const mapTilerKey = String.fromEnvironment('MAPTILER_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static String get tileUrlTemplate {
    if (mapTilerKey.isEmpty) {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }

    return 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$mapTilerKey';
  }
}
