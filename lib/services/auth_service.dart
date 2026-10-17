import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String get userId => currentUser!.id;
  String? get email => currentUser?.email;

  String get displayName {
    final name = currentUser?.userMetadata?['display_name'];
    return name is String ? name : '';
  }

  Future<void> signIn(String email, String password) async {
    await _client.auth
        .signInWithPassword(email: email.trim(), password: password);
  }

  /// Devolve `true` se já ficou com sessão iniciada, `false` se o projeto
  /// exige confirmação por email antes do primeiro login.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': name},
    );
    return res.session != null;
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> updateDisplayName(String name) async {
    await _client.auth.updateUser(UserAttributes(data: {'display_name': name}));
    await _client
        .from('profiles')
        .update({'display_name': name}).eq('id', userId);
  }
}

/// Texto de erro pronto para mostrar ao utilizador (em português).
String errorMessage(Object e) {
  final raw = switch (e) {
    AuthException() => e.message,
    PostgrestException() => e.message,
    StorageException() => e.message,
    _ => e.toString(),
  };
  final lower = raw.toLowerCase();
  if (lower.contains('invalid login credentials')) {
    return 'Email ou senha incorretos';
  }
  if (lower.contains('user already registered') ||
      lower.contains('already been registered')) {
    return 'Já existe uma conta com este email';
  }
  if (lower.contains('email not confirmed')) {
    return 'Confirme o seu email antes de entrar';
  }
  if (lower.contains('rate limit') || lower.contains('too many')) {
    return 'Muitas tentativas. Aguarde um pouco e tente de novo';
  }
  if (lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('clientexception') ||
      lower.contains('network')) {
    return 'Sem conexão com a internet';
  }
  if (lower.contains('password should be at least')) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return raw;
}
