import '.././domain/entities/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    required super.dueDate,
    required super.priority,
    required super.isCompleted,
  });

  // Convert Firestore Document to TaskModel
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: Priority.values.firstWhere(
        (e) => e.toString() == map['priority'],
        orElse: () => Priority.low,
      ),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Convert TaskModel to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.toString(),
      'isCompleted': isCompleted,
    };
  }
}