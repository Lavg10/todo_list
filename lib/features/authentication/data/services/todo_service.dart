import 'package:supabase_flutter/supabase_flutter.dart';

class TodoService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTodos(int page, int pageSize) async {
    final userId = _client.auth.currentUser!.id;

    final response = await _client
        .from('todo')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return response;
  }

  Future<void> addTodo(String task) async {
    final userId = _client.auth.currentUser!.id;

    await _client.from('todo').insert({
      'task': task,
      'status': 'pending',
      'user_id': userId,
    });
  }

  Future<void> updateStatus(int id, String newStatus) async {
    await _client.from('todo').update({'status': newStatus}).eq('id', id);
  }

  Future<void> deleteTodo(int id) async {
    await _client.from('todo').delete().eq('id', id);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
