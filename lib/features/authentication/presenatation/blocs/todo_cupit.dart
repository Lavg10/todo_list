import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/todo_service.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoService _todoService;

  TodoCubit(this._todoService) : super(const TodoState());

  Future<void> fetchTodos() async {
    if (state.isLoading || !state.hasMore) return;

    emit(state.copyWith(isLoading: true));
    try {
      final fetched = await _todoService.fetchTodos(state.page, 10);
      emit(
        state.copyWith(
          todos: [...state.todos, ...fetched],
          page: state.page + 1,
          hasMore: fetched.length == 10,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> addTodo(String task) async {
    await _todoService.addTodo(task);
    await refreshTodos();
  }

  Future<void> updateStatus(int id, String status) async {
    await _todoService.updateStatus(id, status);
    await refreshTodos();
  }

  Future<void> deleteTodo(int id) async {
    await _todoService.deleteTodo(id);
    await refreshTodos();
  }

  Future<void> refreshTodos() async {
    emit(const TodoState());
    await fetchTodos();
  }

  Future<void> logout() async {
    await _todoService.logout();
  }
}
