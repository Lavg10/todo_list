import 'package:equatable/equatable.dart';

class TodoState extends Equatable {
  final List<Map<String, dynamic>> todos;
  final bool isLoading;
  final bool hasMore;
  final int page;

  const TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
  });

  TodoState copyWith({
    List<Map<String, dynamic>>? todos,
    bool? isLoading,
    bool? hasMore,
    int? page,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [todos, isLoading, hasMore, page];
}
