import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management/features/auth/tasks/data/domain/entities/task.dart';
import 'package:task_management/features/auth/tasks/data/repositories/task_repository_impl.dart';
import 'package:flutter_riverpod/legacy.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepositoryImpl());
final searchProvider = StateProvider<String>((ref) => "");

final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(taskRepositoryProvider).getTasks();
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksStreamProvider);
  final query = ref.watch(searchProvider).toLowerCase();

  return tasksAsync.maybeWhen(
    data: (tasks) =>
        tasks.where((t) => t.title.toLowerCase().contains(query)).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
    orElse: () => [],
  );
});
