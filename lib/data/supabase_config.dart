/// Central Supabase connection details, shared by the AI-import Edge Function
/// call and the community backend.
///
/// The anon/publishable key is the project's PUBLIC key — it only grants the
/// row-level-security-scoped access the policies allow, so it is safe to ship
/// inside the app. Override either value at build time when needed:
///   flutter build apk \
///     --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ocfdldqamonkndutuevd.supabase.co',
  );

  /// Public publishable key (safe to ship). Baked in so the community backend
  /// works in release builds without depending on a build flag being passed.
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_mGfJJYo1AMUBvtCYM-TybA_w1aVP1lG',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
