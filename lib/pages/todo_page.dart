import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart'; // add this package in pubspec.yaml
import 'login_page.dart';
import 'profile_screen.dart';

class TodoPage extends StatefulWidget {
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final taskController = TextEditingController();
  List todos = [];
  bool isLoading = false;
  bool hasMore = true;
  int pageSize = 10;
  int page = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTodos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchTodos();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    taskController.dispose();
    super.dispose();
  }

  Future<void> fetchTodos() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final response = await Supabase.instance.client
          .from('todo')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);

      if (response.length < pageSize) {
        hasMore = false;
      }

      setState(() {
        todos.addAll(response);
        page++;
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch todos: $error')));
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addTodo() async {
    final task = taskController.text.trim();
    final userId = Supabase.instance.client.auth.currentUser!.id;

    if (task.isEmpty) return;

    try {
      await Supabase.instance.client.from('todo').insert({
        'task': task,
        'status': 'pending',
        'user_id': userId,
      });

      taskController.clear();

      // Reset pagination and reload todos
      setState(() {
        todos.clear();
        page = 0;
        hasMore = true;
      });
      fetchTodos();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add todo: $error')));
    }
  }

  void updateTodoStatus(int id, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('todo')
          .update({'status': newStatus})
          .eq('id', id);

      // Reload todos
      setState(() {
        todos.clear();
        page = 0;
        hasMore = true;
      });
      fetchTodos();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $error')),
      );
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await Supabase.instance.client.from('todo').delete().eq('id', id);

      setState(() {
        todos.clear();
        page = 0;
        hasMore = true;
      });
      fetchTodos();
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete todo: $error')));
    }
  }

  void logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  Widget buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.white54,
          highlightColor: Colors.white70,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
      controller: _scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Todos'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 83, 202, 202),
              Color.fromARGB(255, 170, 24, 24),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: taskController,
                            decoration: const InputDecoration(
                              hintText: 'Enter a new task',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            size: 30,
                            color: Colors.blueAccent,
                          ),
                          onPressed: addTodo,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: todos.isEmpty && isLoading
                      ? buildShimmer()
                      : todos.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks yet. Start adding!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: todos.length + (hasMore ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index == todos.length) {
                              // show loading indicator
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            final todo = todos[index];
                            final isCompleted = todo['status'] == 'completed';

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isCompleted,
                                  activeColor: Colors.green,
                                  onChanged: (bool? newValue) {
                                    if (newValue != null) {
                                      updateTodoStatus(
                                        todo['id'],
                                        newValue ? 'completed' : 'pending',
                                      );
                                    }
                                  },
                                ),
                                title: Text(
                                  todo['task'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  todo['status'].toUpperCase(),
                                  style: TextStyle(
                                    color: isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: const Text(
                                        'Are you sure you want to delete this task?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            await deleteTodo(todo['id']);
                                          },
                                          child: const Text(
                                            'Yes',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
