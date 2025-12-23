import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../domain/entities/task.dart';

class TaskRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Stream<List<Task>> getTasks() {
    if (_userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addTask(TaskModel task) async {
    if (_userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }
}
