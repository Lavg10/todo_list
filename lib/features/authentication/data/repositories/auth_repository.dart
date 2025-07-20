import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

class AuthRepository {
  final SupabaseClient client;

  AuthRepository(this.client);

  Future<Either<String, void>> login(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return right(null);
      } else {
        return left('No active session');
      }
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<void> register(String email, String password) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception("Registration failed");
    }

    await client.from('profiles').insert({
      'id': response.user!.id,
      'full_name': '',
      'avatar_url': '',
    });
  }
}
