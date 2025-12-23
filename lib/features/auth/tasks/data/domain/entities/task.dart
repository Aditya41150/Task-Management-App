enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });
}