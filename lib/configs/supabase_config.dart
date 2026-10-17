// A chave publicável é pública por desenho: a segurança vem das políticas RLS.
// Nunca ponhas aqui a chave secret/service_role.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fyporaxvvajlbhednzpn.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_Kgd0SmkgTv6AQjLT6ci5rA_Ak8LmA1a',
  );
  static const bucket = 'photos';
}
