import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'todo_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return TodoPage(); // already logged in
    } else {
      return LoginPage(); // default screen
    }
  }
}
