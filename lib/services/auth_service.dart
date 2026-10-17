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

String errorMessage(Object e) {
  if (e is AuthException) return e.message;
  if (e is PostgrestException) return e.message;
  if (e is StorageException) return e.message;
  return e.toString();
}
