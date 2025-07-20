import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../blocs/todo_state.dart';
import '../blocs/todo_cupit.dart';
import '../../../authentication/presenatation/pages/login_page.dart';
import '../../../authentication/presenatation/pages/profile_page.dart';
// import '../../../authentication/ui/login_page.dart';
// import '../../../profile/ui/profile_page.dart';
// import '../../cubit/todo_cubit.dart';
// import '../../cubit/todo_state.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TodoCubit>().fetchTodos();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 200 &&
          !context.read<TodoCubit>().state.isLoading) {
        context.read<TodoCubit>().fetchTodos();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<TodoCubit>().logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5,
      controller: _scrollController,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
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
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter a new task',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            size: 30,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              context.read<TodoCubit>().addTodo(
                                _controller.text.trim(),
                              );
                              _controller.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<TodoCubit, TodoState>(
                    builder: (_, state) {
                      if (state.isLoading && state.todos.isEmpty) {
                        return _buildShimmer();
                      }

                      if (state.todos.isEmpty) {
                        return const Center(
                          child: Text(
                            "No tasks yet. Start adding!",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: state.todos.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (index == state.todos.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }

                          final todo = state.todos[index];
                          final isCompleted = todo['status'] == 'completed';

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: isCompleted,
                                activeColor: Colors.green,
                                onChanged: (val) {
                                  context.read<TodoCubit>().updateStatus(
                                    todo['id'],
                                    val! ? 'completed' : 'pending',
                                  );
                                },
                              ),
                              title: Text(
                                todo['task'],
                                style: TextStyle(
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
                                icon: const Icon(
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
                                          await context
                                              .read<TodoCubit>()
                                              .deleteTodo(todo['id']);
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
